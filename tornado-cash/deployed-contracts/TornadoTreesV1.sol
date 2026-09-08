// SPDX-License-Identifier: Unknown
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

interface ITornadoTrees {
    function registerDeposit(address instance, bytes32 commitment) external;

    function registerWithdrawal(address instance, bytes32 nullifier) external;
}

interface Resolver {
    function addr(bytes32 node) external view returns (address);
}

interface ENS {
    function resolver(bytes32 node) external view returns (Resolver);
}

contract EnsResolve {
    function resolve(bytes32 node) public view virtual returns (address) {
        ENS Registry = ENS(
            getChainId() == 1 ? 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e : 0x8595bFb0D940DfEDC98943FA8a907091203f25EE
        );
        return Registry.resolver(node).addr(node);
    }

    function bulkResolve(bytes32[] memory domains) public view returns (address[] memory result) {
        result = new address[](domains.length);
        for (uint256 i = 0; i < domains.length; i++) {
            result[i] = resolve(domains[i]);
        }
    }

    function getChainId() internal pure returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IHasher {
    function poseidon(bytes32[2] calldata inputs) external pure returns (bytes32);

    function poseidon(bytes32[3] calldata inputs) external pure returns (bytes32);
}

contract MerkleTreeWithHistory {
    uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 public constant ZERO_VALUE = 21663839004416932945382355908790599225266501822907911457504978515578255421292; // = keccak256("tornado") % FIELD_SIZE

    uint32 public immutable levels;
    IHasher public hasher; // todo immutable

    bytes32[] public filledSubtrees;
    bytes32[] public zeros;
    uint32 public currentRootIndex = 0;
    uint32 public nextIndex = 0;
    uint32 public constant ROOT_HISTORY_SIZE = 10;
    bytes32[ROOT_HISTORY_SIZE] public roots;

    constructor(uint32 _treeLevels, IHasher _hasher) public {
        require(_treeLevels > 0, "_treeLevels should be greater than zero");
        require(_treeLevels < 32, "_treeLevels should be less than 32");
        levels = _treeLevels;
        hasher = _hasher;

        bytes32 currentZero = bytes32(ZERO_VALUE);
        zeros.push(currentZero);
        filledSubtrees.push(currentZero);

        for (uint32 i = 1; i < _treeLevels; i++) {
            currentZero = hashLeftRight(currentZero, currentZero);
            zeros.push(currentZero);
            filledSubtrees.push(currentZero);
        }

        filledSubtrees.push(hashLeftRight(currentZero, currentZero));
        roots[0] = filledSubtrees[_treeLevels];
    }

    /**
     * @dev Hash 2 tree leaves, returns poseidon(_left, _right)
     */
    function hashLeftRight(bytes32 _left, bytes32 _right) public view returns (bytes32) {
        return hasher.poseidon([_left, _right]);
    }

    function _insert(bytes32 _leaf) internal returns (uint32 index) {
        uint32 currentIndex = nextIndex;
        require(currentIndex != uint32(2) ** levels, "Merkle tree is full. No more leaves can be added");
        nextIndex = currentIndex + 1;
        bytes32 currentLevelHash = _leaf;
        bytes32 left;
        bytes32 right;

        for (uint32 i = 0; i < levels; i++) {
            if (currentIndex % 2 == 0) {
                left = currentLevelHash;
                right = zeros[i];
                filledSubtrees[i] = currentLevelHash;
            } else {
                left = filledSubtrees[i];
                right = currentLevelHash;
            }

            currentLevelHash = hashLeftRight(left, right);
            currentIndex /= 2;
        }

        currentRootIndex = (currentRootIndex + 1) % ROOT_HISTORY_SIZE;
        roots[currentRootIndex] = currentLevelHash;
        return nextIndex - 1;
    }

    function _bulkInsert(bytes32[] memory _leaves) internal {
        uint32 insertIndex = nextIndex;
        require(
            insertIndex + _leaves.length <= uint32(2) ** levels,
            "Merkle doesn't have enough capacity to add specified leaves"
        );

        bytes32[] memory subtrees = new bytes32[](levels);
        bool[] memory modifiedSubtrees = new bool[](levels);
        for (uint32 j = 0; j < _leaves.length - 1; j++) {
            uint256 index = insertIndex + j;
            bytes32 currentLevelHash = _leaves[j];

            for (uint32 i = 0;; i++) {
                if (index % 2 == 0) {
                    modifiedSubtrees[i] = true;
                    subtrees[i] = currentLevelHash;
                    break;
                }

                if (subtrees[i] == bytes32(0)) {
                    subtrees[i] = filledSubtrees[i];
                }
                currentLevelHash = hashLeftRight(subtrees[i], currentLevelHash);
                index /= 2;
            }
        }

        for (uint32 i = 0; i < levels; i++) {
            // using local map to save on gas on writes if elements were not modified
            if (modifiedSubtrees[i]) {
                filledSubtrees[i] = subtrees[i];
            }
        }

        nextIndex = uint32(insertIndex + _leaves.length - 1);
        _insert(_leaves[_leaves.length - 1]);
    }

    /**
     * @dev Whether the root is present in the root history
     */
    function isKnownRoot(bytes32 _root) public view returns (bool) {
        if (_root == 0) {
            return false;
        }
        uint32 i = currentRootIndex;
        do {
            if (_root == roots[i]) {
                return true;
            }
            if (i == 0) {
                i = ROOT_HISTORY_SIZE;
            }
            i--;
        } while (i != currentRootIndex);
        return false;
    }

    /**
     * @dev Returns the last root
     */
    function getLastRoot() public view returns (bytes32) {
        return roots[currentRootIndex];
    }
}

contract OwnableMerkleTree is Ownable, MerkleTreeWithHistory {
    constructor(uint32 _treeLevels, IHasher _hasher) public MerkleTreeWithHistory(_treeLevels, _hasher) {}

    function insert(bytes32 _leaf) external onlyOwner returns (uint32 index) {
        return _insert(_leaf);
    }

    function bulkInsert(bytes32[] calldata _leaves) external onlyOwner {
        _bulkInsert(_leaves);
    }
}

contract TornadoTrees is ITornadoTrees, EnsResolve {
    OwnableMerkleTree public immutable depositTree;
    OwnableMerkleTree public immutable withdrawalTree;
    IHasher public immutable hasher;
    address public immutable tornadoProxy;

    bytes32[] public deposits;
    uint256 public lastProcessedDepositLeaf;

    bytes32[] public withdrawals;
    uint256 public lastProcessedWithdrawalLeaf;

    event DepositData(address instance, bytes32 indexed hash, uint256 block, uint256 index);
    event WithdrawalData(address instance, bytes32 indexed hash, uint256 block, uint256 index);

    struct TreeLeaf {
        address instance;
        bytes32 hash;
        uint256 block;
    }

    modifier onlyTornadoProxy() {
        require(msg.sender == tornadoProxy, "Not authorized");
        _;
    }

    constructor(bytes32 _tornadoProxy, bytes32 _hasher2, bytes32 _hasher3, uint32 _levels) public {
        tornadoProxy = resolve(_tornadoProxy);
        hasher = IHasher(resolve(_hasher3));
        depositTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
        withdrawalTree = new OwnableMerkleTree(_levels, IHasher(resolve(_hasher2)));
    }

    function registerDeposit(address _instance, bytes32 _commitment) external override onlyTornadoProxy {
        deposits.push(keccak256(abi.encode(_instance, _commitment, blockNumber())));
    }

    function registerWithdrawal(address _instance, bytes32 _nullifier) external override onlyTornadoProxy {
        withdrawals.push(keccak256(abi.encode(_instance, _nullifier, blockNumber())));
    }

    function updateRoots(TreeLeaf[] calldata _deposits, TreeLeaf[] calldata _withdrawals) external {
        if (_deposits.length > 0) {
            updateDepositTree(_deposits);
        }
        if (_withdrawals.length > 0) {
            updateWithdrawalTree(_withdrawals);
        }
    }

    function updateDepositTree(TreeLeaf[] calldata _deposits) public {
        bytes32[] memory leaves = new bytes32[](_deposits.length);
        uint256 offset = lastProcessedDepositLeaf;

        for (uint256 i = 0; i < _deposits.length; i++) {
            TreeLeaf memory deposit = _deposits[i];
            bytes32 leafHash = keccak256(abi.encode(deposit.instance, deposit.hash, deposit.block));
            require(deposits[offset + i] == leafHash, "Incorrect deposit");

            leaves[i] = hasher.poseidon([bytes32(uint256(deposit.instance)), deposit.hash, bytes32(deposit.block)]);
            delete deposits[offset + i];

            emit DepositData(deposit.instance, deposit.hash, deposit.block, offset + i);
        }

        lastProcessedDepositLeaf = offset + _deposits.length;
        depositTree.bulkInsert(leaves);
    }

    function updateWithdrawalTree(TreeLeaf[] calldata _withdrawals) public {
        bytes32[] memory leaves = new bytes32[](_withdrawals.length);
        uint256 offset = lastProcessedWithdrawalLeaf;

        for (uint256 i = 0; i < _withdrawals.length; i++) {
            TreeLeaf memory withdrawal = _withdrawals[i];
            bytes32 leafHash = keccak256(abi.encode(withdrawal.instance, withdrawal.hash, withdrawal.block));
            require(withdrawals[offset + i] == leafHash, "Incorrect withdrawal");

            leaves[i] =
                hasher.poseidon([bytes32(uint256(withdrawal.instance)), withdrawal.hash, bytes32(withdrawal.block)]);
            delete withdrawals[offset + i];

            emit WithdrawalData(withdrawal.instance, withdrawal.hash, withdrawal.block, offset + i);
        }

        lastProcessedWithdrawalLeaf = offset + _withdrawals.length;
        withdrawalTree.bulkInsert(leaves);
    }

    function validateRoots(bytes32 _depositRoot, bytes32 _withdrawalRoot) public view {
        require(depositTree.isKnownRoot(_depositRoot), "Incorrect deposit tree root");
        require(withdrawalTree.isKnownRoot(_withdrawalRoot), "Incorrect withdrawal tree root");
    }

    function depositRoot() external view returns (bytes32) {
        return depositTree.getLastRoot();
    }

    function withdrawalRoot() external view returns (bytes32) {
        return withdrawalTree.getLastRoot();
    }

    function getRegisteredDeposits() external view returns (bytes32[] memory _deposits) {
        uint256 count = deposits.length - lastProcessedDepositLeaf;
        _deposits = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            _deposits[i] = deposits[lastProcessedDepositLeaf + i];
        }
    }

    function getRegisteredWithdrawals() external view returns (bytes32[] memory _withdrawals) {
        uint256 count = withdrawals.length - lastProcessedWithdrawalLeaf;
        _withdrawals = new bytes32[](count);
        for (uint256 i = 0; i < count; i++) {
            _withdrawals[i] = withdrawals[lastProcessedWithdrawalLeaf + i];
        }
    }

    function blockNumber() public view virtual returns (uint256) {
        return block.number;
    }
}
