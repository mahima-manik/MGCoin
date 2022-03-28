# RDCoin

ERC20 = Total Supply 1.5 Billion RD Coins

### Staking contract requirements:

1. 10 percent of the total supply of RDC will be allocated for staking so 150,000,000 million rdc
2. Staked RDC tokens are not liquid and may not be transferred or sold. 
3. Staked RDC tokens may be unstaked over a period of four weeks, with 25% of the total amount of tokens being unstaked becoming available as liquid RDC tokens at the end of each of the four weeks from when the unstaking operation is submitted. 
4. The stake reward vesting should last 60 months for the 10 percent allocation.

Questions:
1. Can one address submit more than one stakes? -> No, cannot withdraw anything for 28 days
2. Can a stake amount be partially withdrawn? -> Yes, upto 25%
3. What is staking allocation (10% of total supply)?
4. What is reward strategy? 10% of amount staked every month for 60 months? Example: if someone staked 100rdc, by end of 60 months - 600 rdc is rewarded (10 rdc every month):
5. Can owner unstake when some reward is already given? Example: 100 rdc staked, 10 months passed (100 rdc rewarded),  on unstake(), owner should be given 25 rdc over 4 weeks?

Approach 1
- burn() token during stake and mint() during withdraw/reward.
- Create a StakingContract
- Call the functions of StakingContract in the RDCoin


**Design:**

Data Members:
```
struct Stake {
    uint amount;    // total amount staked initially (>0)
    uint depositTime;   // initial stake time
    uint withdrawnAmount;   // withdrawn stake amount
    uint lastWithdrawTime; // last withdraw time
    uint lastRewardTime;    // last reward time
    uint rewardAmount;  // total reward given
}

mapping (address => Stake) internal stakes;
```

Methods:

```
/* Stakes given amount for msg.sender */
function stake (uint _amount) returns (bool);

/* Bestows 25% of the stake to msg.sender */
function withdraw (uint _stakeIndex) returns (bool);

/* rewards msg.sender for the stakes added */
function getReward ();

/* Returns list of all active stakes of msg.sender */
function getStakes ();
```

Events:
```
event Stake(address owner, uint amount);
event Reward(address owner, uint amount);
event Withdraw(address owner, uint amount);
```

---

### Airdrop contract requirements:

1. 5 percent of the total supply of RDC will be allocated for airdrop so 75,000,000 million rdc.
2. Rather than have a specific airdrop date and time, RDC tokens will be airdropped to asset holders when new transactions occur at RD Land daily over 1 year. Therefore every early holder can earn RDC airdrop with every transaction, including their own, within the RD Land ecosystem.
3. The airdrop reward vesting should last 12 months for the 5 percent allocation.

Questions:
1. 

**Design**
Create an Airdrop contract and call the functions in RDCoin

Data members:
```
uint dropStartTime; // when RDCoin is deployed
uint lastDropTime;  // time when last airdrop was done to an address
uint dropEndTime;   // 12 months after dropStartTime
uint MAX_LIMIT = 150;
mapping (address => uint) airdrops;
```
Methods:
```
/*
    Check if its been 24 hours since lastDropTime
    Mint one RDCoin to _address
*/
function drop(address _address);
```

### Working

- Create a truffle project

    `truffle init`


- Place the RDCoin.sol file in the contracts folder
- Changed the solidity version to pragma in `truffle-config.js`
- Compile the contract

    `truffle compile`


Questions?
1. Visibility of airdrops and stakes?
Public

Staking must pass test for:
- Users should be able to unstake up to 25 percent of the initial stake every 28 days or 4 weeks.
- Rewards should not exceed 10 percent of the total supply of rdcoin allocated to staking for the period of 60 months
- Users should be able to stake, unstake and redeem rewards

Airdrop must pass test for:
- Airdrops should not exceed over the 5 percent allocation from total supply of rdcoin during the 12 months
- Check for functionality of the drop and drop available functions