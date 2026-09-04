// SPDX-License-Identifier: Unknown
pragma solidity 0.8.26;

interface INetFeeSplitter {
    /// @notice Recipient data for an individual recipient
    /// @custom:field setter The setter address managing the recipient
    /// @custom:field allocation The allocation of the recipient
    struct Recipient {
        address setter;
        uint256 allocation;
    }

    /// @notice Emitted when a recipient's allocation is transferred
    /// @param setter The setter address managing the recipient
    /// @param from The previous recipient address
    /// @param to The new recipient address
    /// @param allocation The allocation transferred
    event AllocationTransferred(address indexed setter, address indexed from, address indexed to, uint256 allocation);

    /// @notice Emitted when a recipient's setter is transferred
    /// @param recipient The recipient address
    /// @param previousSetter The previous setter address
    /// @param newSetter The new setter address
    event SetterTransferred(address indexed recipient, address indexed previousSetter, address indexed newSetter);

    /// @notice Emitted when fees are withdrawn by recipient
    /// @param recipient The recipient address
    /// @param to The address the fees were withdrawn to
    /// @param amount The amount of fees withdrawn
    event Withdrawn(address indexed recipient, address indexed to, uint256 amount);

    /// @notice Thrown when the recipients array is not the same length as the recipientData array
    error InvalidRecipients();

    /// @notice Thrown when a duplicate recipient is added
    error DuplicateRecipient();

    /// @notice Thrown when an setter address is zero
    error SetterZero();

    /// @notice Thrown when a recipient already has a setter
    error SetterAlreadySet();

    /// @notice Thrown when a recipient address is zero
    error RecipientZero();

    /// @notice Thrown when a recipient allocation is zero or zero allocation is transferred
    error AllocationZero();

    /// @notice Thrown when the total allocation is not the same as the sum of the recipient balances
    error InvalidTotalAllocation();

    /// @notice Thrown when the caller is not the setter
    error Unauthorized();

    /// @notice Thrown when there is insufficient allocation to perform a transfer
    error InsufficientAllocation();

    /// @notice Thrown when a withdrawal fails
    error WithdrawalFailed();

    /// @notice Transfers a allocation from one recipient to another
    /// @param oldRecipient The recipient address to transfer from
    /// @param newRecipient The recipient address to transfer to
    /// @param allocation The allocation to transfer
    /// @dev reverts if the recipient doesn't have a setter
    function transferAllocation(address oldRecipient, address newRecipient, uint256 allocation) external;

    /// @notice Transfers the allocation of a recipient to another recipient and sets the setter of the recipient
    /// @param oldRecipient The recipient address to transfer from
    /// @param newRecipient The recipient address to transfer to
    /// @param newSetter The new setter address for the recipient
    /// @param allocation The allocation to transfer
    /// @dev reverts if the recipient already has a setter
    function transferAllocationAndSetSetter(
        address oldRecipient,
        address newRecipient,
        address newSetter,
        uint256 allocation
    ) external;

    /// @notice Transfers the setter of a recipient to a new setter
    /// @param recipient The recipient address
    /// @param newSetter The new setter address
    function transferSetter(address recipient, address newSetter) external;

    /// @notice Withdraws the fees earned by a recipient
    /// @param to The address to withdraw the fees to
    /// @return amount The amount of fees withdrawn
    function withdrawFees(address to) external returns (uint256 amount);

    /// @notice Calculates the fees earned by a recipient
    /// @param account The recipient address
    /// @return amount The amount of fees earned
    function earnedFees(address account) external view returns (uint256);

    /// @notice Gets the allocation of a recipient
    /// @param recipient The recipient address
    /// @return allocation The allocation of the recipient
    function balanceOf(address recipient) external view returns (uint256);

    /// @notice Gets the setter of a recipient
    /// @param recipient The recipient address
    /// @return setter The setter of the recipient
    function setterOf(address recipient) external view returns (address);
}

contract NetFeeSplitter is INetFeeSplitter {
    uint256 internal constant TOTAL_ALLOCATION = 10_000;
    uint256 private constant MAGNITUDE = 1e30;

    uint256 private _index;
    mapping(address recipient => uint256 index) private _indexOf;
    mapping(address recipient => uint256 _earned) private _earned;

    mapping(address recipient => Recipient) public recipients;

    constructor(address[] memory initialRecipients, Recipient[] memory recipientData) {
        uint256 totalAllocation;
        uint256 length = initialRecipients.length;
        if (initialRecipients.length != recipientData.length) revert InvalidRecipients();
        for (uint256 i = 0; i < length; i++) {
            address recipient = initialRecipients[i];
            bool duplicateRecipient = false;
            assembly {
                duplicateRecipient := tload(recipient)
                tstore(recipient, 1)
            }
            if (duplicateRecipient) revert DuplicateRecipient();
            if (recipientData[i].setter == address(0)) revert SetterZero();
            if (recipient == address(0)) revert RecipientZero();
            if (recipientData[i].allocation == 0) revert AllocationZero();
            recipients[recipient] = recipientData[i];
            totalAllocation += recipientData[i].allocation;
        }
        if (totalAllocation != TOTAL_ALLOCATION) revert InvalidTotalAllocation();
    }

    /// @dev Keep track of incoming fees
    receive() external payable {
        _index += (msg.value * MAGNITUDE) / TOTAL_ALLOCATION;
    }

    /// @inheritdoc INetFeeSplitter
    function transferAllocation(address oldRecipient, address newRecipient, uint256 allocation) external {
        if (setterOf(newRecipient) == address(0)) revert SetterZero();
        _transfer(oldRecipient, newRecipient, allocation);
    }

    /// @inheritdoc INetFeeSplitter
    function transferAllocationAndSetSetter(
        address oldRecipient,
        address newRecipient,
        address newSetter,
        uint256 allocation
    ) external {
        if (setterOf(newRecipient) != address(0)) revert SetterAlreadySet();
        if (newSetter == address(0)) revert SetterZero();
        recipients[newRecipient] = Recipient(newSetter, 0);
        emit SetterTransferred(newRecipient, address(0), newSetter);
        _transfer(oldRecipient, newRecipient, allocation);
    }

    /// @inheritdoc INetFeeSplitter
    function transferSetter(address recipient, address newSetter) external {
        if (newSetter == address(0)) revert SetterZero();
        address currentSetter = setterOf(recipient);
        if (currentSetter != msg.sender) revert Unauthorized();
        recipients[recipient].setter = newSetter;
        emit SetterTransferred(recipient, currentSetter, newSetter);
    }

    /// @inheritdoc INetFeeSplitter
    function withdrawFees(address to) external returns (uint256 amount) {
        _updateFees(msg.sender);
        amount = _earned[msg.sender];
        if (amount != 0) {
            _earned[msg.sender] = 0;
            (bool success,) = to.call{value: amount}('');
            if (!success) revert WithdrawalFailed();
        }
        emit Withdrawn(msg.sender, to, amount);
    }

    /// @inheritdoc INetFeeSplitter
    function earnedFees(address account) external view returns (uint256) {
        return _earned[account] + _calculateFees(account);
    }

    /// @inheritdoc INetFeeSplitter
    function balanceOf(address recipient) public view returns (uint256) {
        return recipients[recipient].allocation;
    }

    /// @inheritdoc INetFeeSplitter
    function setterOf(address recipient) public view returns (address) {
        return recipients[recipient].setter;
    }

    function _transfer(address oldRecipient, address newRecipient, uint256 allocation) private {
        if (setterOf(oldRecipient) != msg.sender) revert Unauthorized();
        if (newRecipient == address(0)) revert RecipientZero();
        if (allocation == 0) revert AllocationZero();
        if (balanceOf(oldRecipient) < allocation) revert InsufficientAllocation();
        _updateFees(oldRecipient);
        _updateFees(newRecipient);

        recipients[oldRecipient].allocation -= allocation;
        recipients[newRecipient].allocation += allocation;
        emit AllocationTransferred(msg.sender, oldRecipient, newRecipient, allocation);
    }

    function _updateFees(address account) private {
        _earned[account] += _calculateFees(account);
        _indexOf[account] = _index;
    }

    function _calculateFees(address account) private view returns (uint256) {
        return (recipients[account].allocation * (_index - _indexOf[account])) / MAGNITUDE;
    }
}