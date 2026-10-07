// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../library/Transfer.sol";

interface IRoninGatewayV2 {
    /// @dev Emitted when the assets are depositted
    event Deposited(bytes32 receiptHash, Transfer.Receipt receipt);
    /// @dev Emitted when the withdrawal is requested
    event WithdrawalRequested(bytes32 receiptHash, Transfer.Receipt);
    /// @dev Emitted when the assets are withdrawn on mainchain
    event MainchainWithdrew(bytes32 receiptHash, Transfer.Receipt receipt);
    /// @dev Emitted when the withdrawal signatures is requested
    event WithdrawalSignaturesRequested(bytes32 receiptHash, Transfer.Receipt);
    /// @dev Emitted when the tokens are mapped
    event TokenMapped(address[] roninTokens, address[] mainchainTokens, uint256[] chainIds);

    /**
     * @dev Returns withdrawal count.
     */
    function withdrawalCount() external view returns (uint256);

    /**
     * @dev Returns withdrawal signatures.
     */
    function getWithdrawalSignatures(uint256 _withdrawalId, address[] calldata _validators)
        external
        view
        returns (bytes[] memory);

    /**
     * @dev Deposits based on the receipt.
     *
     * Requirements:
     * - The method caller is a validator.
     *
     * Emits the `Deposited` once the assets are released.
     *
     * @notice The assets will be transferred whenever the valid call passes the quorum threshold.
     *
     */
    function depositFor(Transfer.Receipt calldata _receipt) external;

    /**
     * @dev Marks the withdrawal is done on mainchain.
     *
     * Requirements:
     * - The method caller is a validator.
     *
     * Emits the `MainchainWithdrew` event.
     *
     */
    function acknowledgeMainchainWithdrew(uint256 _withdrawalId) external;

    /**
     * @dev Bulk deposits based on the receipt.
     *
     * Requirements:
     * - The method caller is a validator.
     *
     * Emits the `Deposited` once the assets are released.
     *
     * @notice The assets will be transferred whenever the valid call for the receipt passes the quorum threshold.
     *
     */
    function bulkDepositFor(Transfer.Receipt[] calldata _receipts) external;

    /**
     * @dev Locks the assets and request withdrawal.
     *
     * Emits the `WithdrawalRequested` event.
     *
     */
    function requestWithdrawalFor(Transfer.Request calldata _request, uint256 _chainId) external;

    /**
     * @dev Bulk requests withdrawals.
     *
     * Emits the `WithdrawalRequested` events.
     *
     */
    function bulkRequestWithdrawalFor(Transfer.Request[] calldata _requests, uint256 _chainId) external;

    /**
     * @dev Requests withdrawal signatures for a specific withdrawal.
     *
     * Emits the `WithdrawalSignaturesRequested` event.
     *
     */
    function requestWithdrawalSignatures(uint256 _withdrawalId) external;

    /**
     * @dev Submits withdrawal signatures.
     *
     * Requirements:
     * - The method caller is a validator.
     *
     */
    function bulkSubmitWithdrawalSignatures(uint256[] calldata _withdrawals, bytes[] calldata _signatures) external;

    /**
     * @dev Maps Ronin tokens to mainchain networks.
     *
     * Requirement:
     * - The method caller is admin.
     * - The arrays have the same length and its length larger than 0.
     *
     * Emits the `TokenMapped` event.
     *
     */
    function mapTokens(
        address[] calldata _roninTokens,
        address[] calldata _mainchainTokens,
        uint256[] calldata chainIds
    ) external;

    /**
     * @dev Returns mainchain token address.
     * Reverts for unsupported token.
     */
    function getMainchainToken(address _roninToken, uint256 _chainId) external view returns (address);
}
