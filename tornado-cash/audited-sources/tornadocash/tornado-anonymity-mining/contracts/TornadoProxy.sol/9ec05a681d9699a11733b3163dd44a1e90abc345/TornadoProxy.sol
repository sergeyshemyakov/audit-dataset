// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./interfaces/ITornado.sol";
import "./interfaces/ITornadoTrees.sol";
import "torn-token/contracts/ENS.sol";

contract TornadoProxy is EnsResolve {
    ITornadoTrees public immutable tornadoTrees;
    address public immutable governance;

    mapping(ITornado => bool) public instances;

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not authorized");
        _;
    }

    constructor(bytes32 _tornadoTrees, bytes32 _governance, ITornado[] memory _instances) public {
        tornadoTrees = ITornadoTrees(resolve(_tornadoTrees));
        governance = resolve(_governance);

        for (uint256 i = 0; i < _instances.length; i++) {
            instances[_instances[i]] = true;
        }
    }

    function deposit(ITornado tornado, bytes32 commitment) external payable {
        require(instances[tornado], "The instance is not supported");

        tornado.deposit{value: msg.value}(commitment);
        tornadoTrees.registerNewDeposit(address(tornado), commitment);
    }

    function updateInstances(ITornado instance, bool update) external onlyGovernance {
        instances[instance] = update;
    }

    function withdraw(
        ITornado tornado,
        bytes calldata proof,
        bytes32 root,
        bytes32 nullifierHash,
        address payable recipient,
        address payable relayer,
        uint256 fee,
        uint256 refund
    ) external payable {
        require(instances[tornado], "The instance is not supported");

        tornado.withdraw{value: msg.value}(proof, root, nullifierHash, recipient, relayer, fee, refund);
        tornadoTrees.registerNewWithdrawal(address(tornado), nullifierHash);
    }
}
