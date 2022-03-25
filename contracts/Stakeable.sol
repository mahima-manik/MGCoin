// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Stakeable {

    struct Stake {
        uint amount;            // total amount staked initially (>0)
        uint depositTime;       // initial stake time
        uint withdrawnAmount;   // withdrawn stake amount
        uint lastWithdrawTime;  // last withdraw time
        uint lastRewardTime;    // last reward time
    }

    event Staked(address account, uint amount);
    event Reward(address account, uint amount);
    event Withdraw(address account, uint amount);

    mapping (address => Stake) private stakes;
    uint constant ONE_WEEK = 604800000;
    uint constant ONE_MONTH = 2629800000;

    modifier sanityCheck (address account, uint amount) {
        require(amount > 0, "stake amount <= 0");
        require(account != address(0), "cannot be zero address");
        _;
    }

    function stake (address account, uint256 amount) internal sanityCheck(account, amount) { 
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        if (_stake.amount == 0) {
            _stake.depositTime = currentTime;
            _stake.lastWithdrawTime = currentTime;
            _stake.lastRewardTime = currentTime;
        }
        _stake.amount += amount;
    }
    
    function withdraw(address account, uint amount) internal sanityCheck(account, amount) {
        
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        
        // Check withdraw conditions
        require (_stake.amount > 0, "stake amount <= 0");
        uint withdrawLimit = (_stake.amount * 25) / 100;
        
        if (withdrawLimit <= amount) {
            revert ("withdraw limit exceeded");
        }
        
        if (_stake.amount - _stake.withdrawnAmount <= 0)   {
            revert ("amount not available to withdraw");
        }
        
        if (!timeDifference(_stake.lastWithdrawTime, currentTime, ONE_WEEK))   {
            revert ("cannot withdraw before one week");
        }

        _stake.withdrawnAmount += amount;
        _stake.lastWithdrawTime = currentTime;
        
        // TODO: Reset the _stake.amount to 0 when everything is withdrawn
        uint stakedAmount = _stake.amount - _stake.withdrawnAmount;

        // All staked token is withdrawn
        if (stakedAmount == 0)  {
            _stake.amount = 0;
            _stake.depositTime = 0;
            _stake.lastRewardTime = 0;
            _stake.lastWithdrawTime = 0;
            _stake.withdrawnAmount = 0;
            revert("no token staked");
        }
    }
    
    function reward(address account) internal returns (uint) {
        uint currentTime = block.timestamp;
        Stake storage _stake = stakes[account];
        
        // Check reward condition
        bool isEligible = timeDifference(_stake.lastWithdrawTime, currentTime, ONE_MONTH);
        require(isEligible, "cannot reward before one month");

        uint stakedAmount = _stake.amount - _stake.withdrawnAmount;

        // All staked token is withdrawn
        if (stakedAmount == 0)  {
            _stake.amount = 0;
            _stake.depositTime = 0;
            _stake.lastRewardTime = 0;
            _stake.lastWithdrawTime = 0;
            _stake.withdrawnAmount = 0;
            revert("no token staked");
        }

        uint rewardAmount = (stakedAmount * 10) / 100;
        
        _stake.lastRewardTime = currentTime;
        return rewardAmount;
    }

    function getStakes(address account) internal view returns (uint) {
        Stake storage _stake = stakes[account];
        if (_stake.amount == 0) return 0;
        return _stake.amount - _stake.withdrawnAmount;
    }

    function timeDifference(uint from, uint to, uint difference) private pure returns (bool diff) {
        (to - from > difference) ? diff = true : diff = false;
    }

}