// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IRewardSwap.sol";
import "./IVerifier.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "torn-token/contracts/ENS.sol";

contract Miner is Ownable, EnsResolve {
    IVerifier public rewardVerifier;
    IVerifier public withdrawVerifier;
    IVerifier public treeUpdateVerifier;
    IRewardSwap public rewardSwap;
    address public governance;

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

    event NewAccount(bytes32 commitment, bytes32 nullifier, bytes encryptedAccount, uint256 index);
    event DepositData(address instance, bytes32 indexed hash, uint256 block, uint256 index);
    event WithdrawalData(address instance, bytes32 indexed hash, uint256 block, uint256 index);
    event RateChanged(address instance, uint256 value);

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

    struct Rate {
        address instance;
        uint256 value;
    }

    modifier onlyOperator() {
        require(msg.sender == owner(), "Only operator can perform this action");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "Only governance can perform this action");
        _;
    }

    constructor(
        bytes32 _rewardSwap,
        bytes32 _governance,
        bytes32[] memory verifiers,
        bytes32 _accountRoot,
        bytes32 _depositRoot,
        bytes32 _withdrawalRoot,
        Rate[] memory _rates
    ) public {
        rewardSwap = IRewardSwap(resolve(_rewardSwap));
        governance = resolve(_governance);
        rewardVerifier = IVerifier(resolve(verifiers[0]));
        withdrawVerifier = IVerifier(resolve(verifiers[1]));
        treeUpdateVerifier = IVerifier(resolve(verifiers[2]));

        depositRoot = _depositRoot;
        withdrawalRoot = _withdrawalRoot;
        insertAccountRoot(_accountRoot);

        _setRates(_rates);
    }

    function reward(bytes memory _proof, RewardArgs memory _args) public {
        reward(_proof, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
    }

    function batchReward(bytes[] calldata _rewardArgs) external {
        for (uint256 i = 0; i < _rewardArgs.length; i++) {
            (bytes memory proof, RewardArgs memory args) = abi.decode(_rewardArgs[i], (bytes, RewardArgs));
            reward(proof, args);
        }
    }

    function reward(
        bytes memory _proof,
        RewardArgs memory _args,
        bytes memory _treeUpdateProof,
        TreeUpdateArgs memory _treeUpdateArgs
    ) public {
        validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
        require(_args.extDataHash == keccak252(abi.encode(_args.extData)), "Incorrect external data hash");
        require(_args.fee < 2 ** 248, "Fee value out of range");
        require(_args.rate == rates[_args.instance] && _args.rate > 0, "Invalid reward rate");
        require(
            _args.depositRoot == depositRoot || _args.depositRoot == previousDepositRoot, "Outdated deposit merkle root"
        );
        require(
            _args.withdrawalRoot == withdrawalRoot || _args.withdrawalRoot == previousWithdrawalRoot,
            "Outdated withdrawal merkle root"
        );
        require(!rewardNullifiers[_args.rewardNullifier], "Reward has been already spent");
        require(
            rewardVerifier.verifyProof(
                _proof,
                [
                    uint256(_args.rate),
                    uint256(_args.fee),
                    uint256(_args.instance),
                    uint256(_args.rewardNullifier),
                    uint256(_args.extDataHash),
                    uint256(_args.account.inputRoot),
                    uint256(_args.account.inputNullifierHash),
                    uint256(_args.account.outputRoot),
                    uint256(_args.account.outputPathIndices),
                    uint256(_args.account.outputCommitment),
                    uint256(_args.depositRoot),
                    uint256(_args.withdrawalRoot)
                ]
            ),
            "Invalid reward proof"
        );

        accountNullifiers[_args.account.inputNullifierHash] = true;
        rewardNullifiers[_args.rewardNullifier] = true;
        insertAccountRoot(
            _args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot
        );
        if (_args.fee > 0) {
            rewardSwap.swap(_args.extData.relayer, _args.fee);
        }

        emit NewAccount(
            _args.account.outputCommitment,
            _args.account.inputNullifierHash,
            _args.extData.encryptedAccount,
            currentAccountIndex++
        );
    }

    function withdraw(bytes memory _proof, WithdrawArgs memory _args) public {
        withdraw(_proof, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
    }

    function withdraw(
        bytes memory _proof,
        WithdrawArgs memory _args,
        bytes memory _treeUpdateProof,
        TreeUpdateArgs memory _treeUpdateArgs
    ) public {
        validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
        require(_args.extDataHash == keccak252(abi.encode(_args.extData)), "Incorrect external data hash");
        require(_args.amount < 2 ** 248, "Amount value out of range");
        require(_args.fee < 2 ** 248, "Fee value out of range");
        require(
            withdrawVerifier.verifyProof(
                _proof,
                [
                    uint256(_args.amount),
                    uint256(_args.fee),
                    uint256(_args.extDataHash),
                    uint256(_args.account.inputRoot),
                    uint256(_args.account.inputNullifierHash),
                    uint256(_args.account.outputRoot),
                    uint256(_args.account.outputPathIndices),
                    uint256(_args.account.outputCommitment)
                ]
            ),
            "Invalid withdrawal proof"
        );

        insertAccountRoot(
            _args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot
        );
        accountNullifiers[_args.account.inputNullifierHash] = true;
        // allow submitting noop withdrawals (amount == 0)
        if (_args.amount > 0) {
            rewardSwap.swap(_args.extData.recipient, _args.amount);
        }
        // Note. The relayer swap rate always will be worse than estimated
        if (_args.fee > 0) {
            rewardSwap.swap(_args.extData.relayer, _args.fee);
        }

        emit NewAccount(
            _args.account.outputCommitment,
            _args.account.inputNullifierHash,
            _args.extData.encryptedAccount,
            currentAccountIndex++
        );
    }

    function updateRoots(
        bytes32 _currentDepositRoot,
        bytes32 _newDepositRoot,
        TreeLeaf[] calldata _deposits,
        bytes32 _currentWithdrawalRoot,
        bytes32 _newWithdrawalRoot,
        TreeLeaf[] calldata _withdrawals
    ) external onlyOperator {
        if (_deposits.length > 0) {
            // We explicitly check last root to ensure that it's consistent with what updating transaction expects
            require(_currentDepositRoot == depositRoot, "Last root value is incorrect");
            previousDepositRoot = _currentDepositRoot;
            depositRoot = _newDepositRoot;
            for (uint256 i = 0; i < _deposits.length; i++) {
                emit DepositData(_deposits[i].instance, _deposits[i].hash, _deposits[i].block, _deposits[i].index);
            }
        }

        if (_withdrawals.length > 0) {
            // We explicitly check last root to ensure that it's consistent with what updating transaction expects
            require(_currentWithdrawalRoot == withdrawalRoot, "Last root value is incorrect");
            previousWithdrawalRoot = _currentWithdrawalRoot;
            withdrawalRoot = _newWithdrawalRoot;
            for (uint256 i = 0; i < _withdrawals.length; i++) {
                emit WithdrawalData(
                    _withdrawals[i].instance, _withdrawals[i].hash, _withdrawals[i].block, _withdrawals[i].index
                );
            }
        }
    }

    function setRates(Rate[] memory _rates) external onlyGovernance {
        _setRates(_rates);
    }

    function _setRates(Rate[] memory _rates) internal {
        for (uint256 i = 0; i < _rates.length; i++) {
            require(_rates[i].value < 2 ** 128, "Incorrect rate");
            rates[_rates[i].instance] = _rates[i].value;
            emit RateChanged(_rates[i].instance, _rates[i].value);
        }
    }

    function setPoolWeight(uint256 newWeight) external onlyGovernance {
        rewardSwap.setPoolWeight(newWeight);
    }

    // ------VIEW-------

    /**
     * @dev Whether the root is present in the root history
     */
    function isKnownAccountRoot(bytes32 _root) public view returns (bool) {
        if (_root == 0) {
            return false;
        }
        uint256 start = currentAccountRootIndex;
        uint256 end = start > ACCOUNT_ROOT_HISTORY_SIZE ? start - ACCOUNT_ROOT_HISTORY_SIZE : 0;
        // start + 1 to prevent i overflow
        for (uint256 i = start + 1; i > end + 1; i--) {
            if (accountRoots[(i - 1) % ACCOUNT_ROOT_HISTORY_SIZE] == _root) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Returns the last root
     */
    function getLastAccountRoot() public view returns (bytes32) {
        return accountRoots[currentAccountRootIndex % ACCOUNT_ROOT_HISTORY_SIZE];
    }

    // -----INTERNAL-------

    function keccak252(bytes memory data) internal pure returns (bytes32) {
        return keccak256(data) & 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    function validateTreeUpdate(bytes memory _proof, TreeUpdateArgs memory _args, bytes32 _commitment) internal view {
        require(_proof.length > 0, "Outdated account merkle root");
        require(_args.oldRoot == getLastAccountRoot(), "Outdated tree update merkle root");
        require(_args.leaf == _commitment, "Incorrect commitment inserted");
        require(_args.pathIndices == currentAccountIndex, "Incorrect account insert index");
        require(
            treeUpdateVerifier.verifyProof(
                _proof,
                [uint256(_args.oldRoot), uint256(_args.newRoot), uint256(_args.leaf), uint256(_args.pathIndices)]
            ),
            "Invalid tree update proof"
        );
    }

    function validateAccountUpdate(
        AccountUpdate memory _account,
        bytes memory _treeUpdateProof,
        TreeUpdateArgs memory _treeUpdateArgs
    ) internal view {
        require(!accountNullifiers[_account.inputNullifierHash], "Outdated account state");
        if (_account.inputRoot != getLastAccountRoot()) {
            require(isKnownAccountRoot(_account.inputRoot), "Invalid account root");
            validateTreeUpdate(_treeUpdateProof, _treeUpdateArgs, _account.outputCommitment);
        } else {
            require(_account.outputPathIndices == currentAccountIndex, "Incorrect account insert index");
        }
    }

    function insertAccountRoot(bytes32 _root) internal {
        currentAccountRootIndex++;
        accountRoots[currentAccountRootIndex % ACCOUNT_ROOT_HISTORY_SIZE] = _root;
    }
}
