pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

import "./IVerifier.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Farm is Ownable {
    IVerifier public rewardVerifier;
    IVerifier public withdrawVerifier;
    IVerifier public treeUpdateVerifier;
    IERC20 public torn;

    mapping(bytes32 => bool) public deposits;
    mapping(bytes32 => bool) public withdrawals;
    mapping(bytes32 => bool) public accountNullifiers;
    mapping(bytes32 => bool) public rewardNullifiers;
    mapping(address => uint256) public rates;

    // We store previous roots to prevent race condition between
    // root updates and reward() calls
    bytes32 public depositRoot;
    bytes32 public previousDepositRoot;
    bytes32 public withdrawalRoot;
    bytes32 public previousWithdrawalRoot;

    uint256 public currentAccountIndex;
    uint256 public currentAccountRootIndex;
    uint32 public constant ACCOUNT_ROOT_HISTORY_SIZE = 100;
    bytes32[ACCOUNT_ROOT_HISTORY_SIZE] public accountRoots;

    event AccountCommitment(bytes32 commitment, uint256 index);
    event DepositData(address instance, bytes32 hash, uint256 block, uint256 index);
    event WithdrawalData(address instance, bytes32 hash, uint256 block, uint256 index);
    event AccountNullifier(bytes32 nullifier);
    event RewardNullifier(bytes32 nullifier);
    event AccountData(bytes data);

    struct TreeLeaf {
        address instance;
        bytes32 hash;
        uint256 block;
        uint256 index;
    }

    struct TreeUpdateArgs {
        bytes32 oldRoot;
        bytes32 newRoot;
        bytes32 leaf;
        uint256 pathIndices;
    }

    struct AccountUpdate {
        bytes32 inputRoot;
        bytes32 inputNullifierHash;
        bytes32 outputRoot;
        uint256 outputPathIndices;
        bytes32 outputCommitment;
    }

    struct RewardExtData {
        address relayer;
        bytes encryptedAccount;
    }

    struct RewardArgs {
        uint256 rate;
        uint256 fee;
        address instance;
        bytes32 rewardNullifier;
        bytes32 extDataHash;
        bytes32 depositRoot;
        bytes32 withdrawalRoot;
        RewardExtData extData;
        AccountUpdate account;
    }

    struct WithdrawExtData {
        address recipient;
        address relayer;
        bytes encryptedAccount;
    }

    struct WithdrawArgs {
        uint256 amount;
        uint256 fee;
        bytes32 extDataHash;
        WithdrawExtData extData;
        AccountUpdate account;
    }

    constructor(
        address _torn,
        address _rewardVerifier,
        address _withdrawVerifier,
        address _treeUpdateVerifier,
        bytes32 _accountRoot,
        bytes32 _depositRoot,
        bytes32 _withdrawalRoot,
        address[] memory _instances,
        uint256[] memory _rates
    ) public {
        torn = IERC20(_torn);
        rewardVerifier = IVerifier(_rewardVerifier);
        withdrawVerifier = IVerifier(_withdrawVerifier);
        treeUpdateVerifier = IVerifier(_treeUpdateVerifier);

        depositRoot = _depositRoot;
        withdrawalRoot = _withdrawalRoot;
        insertAccountRoot(_accountRoot);

        require(_instances.length == _rates.length, "Invalid rates");

        for (uint256 i = 0; i < _instances.length; i++) {
            setRate(_instances[i], _rates[i]);
        }
    }

    function reward(bytes memory proof, RewardArgs memory args) public {
        reward(proof, args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
    }

    function batchReward(bytes[] calldata rewardArgs) external {
        for (uint256 i = 0; i < rewardArgs.length; i++) {
            (bytes memory proof, RewardArgs memory args) = abi.decode(rewardArgs[i], (bytes, RewardArgs));
            reward(proof, args);
        }
    }

    function reward(
        bytes memory proof,
        RewardArgs memory args,
        bytes memory treeUpdateProof,
        TreeUpdateArgs memory treeUpdateArgs
    ) public {
        validateAccountUpdate(args.account, treeUpdateProof, treeUpdateArgs);
        require(args.extDataHash == cutFirstByte(keccak256(abi.encode(args.extData))), "Incorrect external data hash");
        require(args.fee < 2 ** 248, "Fee value out of range");
        require(args.rate == rates[args.instance], "Invalid reward rate");
        require(
            args.depositRoot == depositRoot || args.depositRoot == previousDepositRoot, "Outdated deposit merkle root"
        );
        require(
            args.withdrawalRoot == withdrawalRoot || args.withdrawalRoot == previousWithdrawalRoot,
            "Outdated withdrawal merkle root"
        );
        require(!rewardNullifiers[args.rewardNullifier], "Reward has been already spent");
        require(
            rewardVerifier.verifyProof(
                proof,
                [
                    uint256(args.rate),
                    uint256(args.fee),
                    uint256(args.instance),
                    uint256(args.rewardNullifier),
                    uint256(args.extDataHash),
                    uint256(args.account.inputRoot),
                    uint256(args.account.inputNullifierHash),
                    uint256(args.account.outputRoot),
                    uint256(args.account.outputPathIndices),
                    uint256(args.account.outputCommitment),
                    uint256(args.depositRoot),
                    uint256(args.withdrawalRoot)
                ]
            ),
            "Invalid reward proof"
        );

        accountNullifiers[args.account.inputNullifierHash] = true;
        rewardNullifiers[args.rewardNullifier] = true;
        insertAccountRoot(
            args.account.inputRoot == getLastAccountRoot() ? args.account.outputRoot : treeUpdateArgs.newRoot
        );
        if (args.fee > 0) {
            torn.transfer(args.extData.relayer, args.fee);
        }

        emit AccountCommitment(args.account.outputCommitment, currentAccountIndex++);
        emit AccountNullifier(args.account.inputNullifierHash);
        emit RewardNullifier(args.rewardNullifier);
        emit AccountData(args.extData.encryptedAccount);
    }

    function withdraw(bytes memory proof, WithdrawArgs memory args) public {
        withdraw(proof, args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
    }

    function withdraw(
        bytes memory proof,
        WithdrawArgs memory args,
        bytes memory treeUpdateProof,
        TreeUpdateArgs memory treeUpdateArgs
    ) public {
        validateAccountUpdate(args.account, treeUpdateProof, treeUpdateArgs);
        require(args.extDataHash == cutFirstByte(keccak256(abi.encode(args.extData))), "Incorrect external data hash");
        require(args.amount < 2 ** 248, "Amount value out of range");
        require(args.fee < 2 ** 248, "Fee value out of range");
        require(
            withdrawVerifier.verifyProof(
                proof,
                [
                    uint256(args.amount),
                    uint256(args.fee),
                    uint256(args.extDataHash),
                    uint256(args.account.inputRoot),
                    uint256(args.account.inputNullifierHash),
                    uint256(args.account.outputRoot),
                    uint256(args.account.outputPathIndices),
                    uint256(args.account.outputCommitment)
                ]
            ),
            "Invalid withdrawal proof"
        );

        insertAccountRoot(
            args.account.inputRoot == getLastAccountRoot() ? args.account.outputRoot : treeUpdateArgs.newRoot
        );
        accountNullifiers[args.account.inputNullifierHash] = true;
        // allow submitting noop withdrawals (amount == 0)
        if (args.amount > 0) {
            torn.transfer(args.extData.recipient, args.amount);
        }
        if (args.fee > 0) {
            torn.transfer(args.extData.relayer, args.fee);
        }

        emit AccountCommitment(args.account.outputCommitment, currentAccountIndex++);
        emit AccountNullifier(args.account.inputNullifierHash);
        emit AccountData(args.extData.encryptedAccount);
    }

    function updateRoots(
        bytes32 _previousDepositRoot,
        bytes32 _depositRoot,
        TreeLeaf[] calldata _deposits,
        bytes32 _previousWithdrawalRoot,
        bytes32 _withdrawalRoot,
        TreeLeaf[] calldata _withdrawals
    ) external onlyOwner {
        if (_deposits.length > 0) {
            // We explicitly check last root to ensure that it's consistent with what updating transaction expects
            require(_previousDepositRoot == depositRoot, "Last root value is incorrect");
            previousDepositRoot = depositRoot;
            depositRoot = _depositRoot;
            for (uint256 i = 0; i < _deposits.length; i++) {
                emit DepositData(_deposits[i].instance, _deposits[i].hash, _deposits[i].block, _deposits[i].index);
            }
        }

        if (_withdrawals.length > 0) {
            // We explicitly check last root to ensure that it's consistent with what updating transaction expects
            require(_previousWithdrawalRoot == withdrawalRoot, "Last root value is incorrect");
            previousWithdrawalRoot = withdrawalRoot;
            withdrawalRoot = _withdrawalRoot;
            for (uint256 i = 0; i < _withdrawals.length; i++) {
                emit WithdrawalData(
                    _withdrawals[i].instance, _withdrawals[i].hash, _withdrawals[i].block, _withdrawals[i].index
                );
            }
        }
    }

    function setRate(address _instance, uint256 _rate) public onlyOwner {
        rates[_instance] = _rate;
    }

    // ------VIEW-------

    function cutFirstByte(bytes32 source) public pure returns (bytes32) {
        return source & 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    /**
     * @dev Whether the root is present in the root history
     */
    function isKnownAccountRoot(bytes32 _root) public view returns (bool) {
        if (_root == 0) {
            return false;
        }
        uint256 i = currentAccountRootIndex;
        do {
            if (_root == accountRoots[i]) {
                return true;
            }
            if (i == 0) {
                i = ACCOUNT_ROOT_HISTORY_SIZE;
            }
            i--;
        } while (i != currentAccountRootIndex);
        return false;
    }

    /**
     * @dev Returns the last root
     */
    function getLastAccountRoot() public view returns (bytes32) {
        return accountRoots[currentAccountRootIndex];
    }

    // -----INTERNAL-------

    function validateTreeUpdate(bytes memory treeUpdateProof, TreeUpdateArgs memory treeUpdateArgs, bytes32 commitment)
        internal
        view
    {
        require(treeUpdateProof.length > 0, "Outdated account merkle root");
        require(treeUpdateArgs.oldRoot == getLastAccountRoot(), "Outdated tree update merkle root");
        require(treeUpdateArgs.leaf == commitment, "Incorrect commitment inserted");
        require(treeUpdateArgs.pathIndices == currentAccountIndex, "Incorrect account insert index");
        require(
            treeUpdateVerifier.verifyProof(
                treeUpdateProof,
                [
                    uint256(treeUpdateArgs.oldRoot),
                    uint256(treeUpdateArgs.newRoot),
                    uint256(treeUpdateArgs.leaf),
                    uint256(treeUpdateArgs.pathIndices)
                ]
            ),
            "Invalid tree update proof"
        );
    }

    function validateAccountUpdate(
        AccountUpdate memory account,
        bytes memory treeUpdateProof,
        TreeUpdateArgs memory treeUpdateArgs
    ) internal view {
        if (account.inputRoot != getLastAccountRoot()) {
            require(isKnownAccountRoot(account.inputRoot), "Invalid account root");
            validateTreeUpdate(treeUpdateProof, treeUpdateArgs, account.outputCommitment);
        } else {
            require(account.outputPathIndices == currentAccountIndex, "Incorrect account insert index");
        }
        require(!accountNullifiers[account.inputNullifierHash], "Outdated account state");
    }

    function insertAccountRoot(bytes32 root) internal {
        currentAccountRootIndex = (currentAccountRootIndex + 1) % ACCOUNT_ROOT_HISTORY_SIZE;
        accountRoots[currentAccountRootIndex] = root;
    }
}
