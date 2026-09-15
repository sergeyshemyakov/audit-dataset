// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

/**
 * Let's imagine we have 1M TORN tokens for anonymity mining to distribute during 1 year (~31536000 seconds).
 *   The contract should constantly add liquidity to a pool of claimed rewards to TORN (REWD/TORN). At any time user can exchange REWD->TORN using
 *   this pool. The rate depends on current available TORN liquidity - the more TORN are withdrawn the worse the swap rate is.
 *
 *   The contract starts with some virtual balance liquidity and adds some TORN tokens every second to the balance. Users will decrease
 *   this balance by swaps.
 *
 *   Exchange rate can be calculated as following:
 *   BalanceAfter = BalanceBefore * e^(-rewardAmount/poolWeight)
 *   tokens = BalanceBefore - BalanceAfter
 */
contract RewardSwap {
    using SafeMath for uint256;

    uint256 public constant DURATION = 365 days;
    uint256 public constant INITIAL_SHARE = 12;

    IERC20 public torn;
    address public miner;
    uint256 public tornBalance;
    uint256 public endTimestamp;
    uint256 public lastSwapTimestamp;
    uint256 public liquidity;
    uint256 public poolWeight = 1e10;

    modifier onlyMiner() {
        require(msg.sender == miner, "Only Miner contract can call");
        _;
    }

    constructor(address _torn, uint256 _miningCap) public {
        torn = IERC20(_torn);
        tornBalance = _miningCap.div(INITIAL_SHARE);
        liquidity = _miningCap.sub(tornBalance);
        endTimestamp = getTimestamp().add(DURATION);
        lastSwapTimestamp = getTimestamp();
    }

    function init(address _miner) external {
        require(miner == address(0), "can be set only once");
        miner = _miner;
    }

    // prettier-ignore
    function swap(address recipient, uint256 amount) external onlyMiner {
        (uint256 oldBalance, uint256 newBalance) = getBalanceUpdate(amount);
        tornBalance = newBalance;
        lastSwapTimestamp = getTimestamp();
        require(torn.transfer(recipient, oldBalance.sub(newBalance)), "transfer failed");
    }

    /**
     * @dev
     */
    function getExpectedReturn(uint256 amount) public view returns (uint256) {
        (uint256 oldBalance, uint256 newBalance) = getBalanceUpdate(amount);
        return oldBalance.sub(newBalance);
    }

    function getBalanceUpdate(uint256 amount) public view returns (uint256 oldBalance, uint256 newBalance) {
        oldBalance = tornVirtualBalance();
        int128 pow = Math.neg(Math.divu(amount, poolWeight));
        int128 exp = Math.exp(pow);
        newBalance = Math.mulu(exp, oldBalance);
    }

    function tornVirtualBalance() public view returns (uint256) {
        uint256 currentTimestamp = getTimestamp();
        if (currentTimestamp < endTimestamp) {
            uint256 passedTime = currentTimestamp.sub(lastSwapTimestamp);
            uint256 increment = liquidity.mul(passedTime).div(DURATION);
            return tornBalance.add(increment);
        } else {
            return torn.balanceOf(address(this));
        }
    }

    function setPoolWeight(uint256 newWeight) external onlyMiner {
        poolWeight = newWeight;
    }

    function getTimestamp() public view virtual returns (uint256) {
        return block.timestamp;
    }
}
