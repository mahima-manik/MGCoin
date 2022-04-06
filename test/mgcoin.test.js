const Stakeable = artifacts.require("Stakeable");
const Airdrop = artifacts.require("Airdrop");
const MGCoin = artifacts.require("MGCoin");
const truffleAssert = require('truffle-assertions');
const { time } = require('@openzeppelin/test-helpers');
const { expectRevert } = require('@openzeppelin/test-helpers');

contract("MGCoin", (accounts) => {
  
  const stakingAmount = 1000;
  let initialBalance = 0;
  before(async () => {
    stakeContract = await Stakeable.deployed();
    airdropContract = await Airdrop.deployed();
    mgcoinContract = await MGCoin.deployed();
    initialBalance = await mgcoinContract.balanceOf(accounts[0]);
  });

  // Assert fail
  it ('Withdraw without staking', async() => {
        // expecting to revert
        await expectRevert(mgcoinContract.reward({from: accounts[0]}), 
            "no token staked");
  })


  it ('Add stakes above MAX_ALLOWED_STAKES', async () => {
    const stakingAmount = 150000001;

    // expecting to revert
    truffleAssert.reverts(mgcoinContract.stake(stakingAmount, {from: accounts[0]}), 'total stakes exceeded 150000000');
  });

  it ('Add stakes', async () => {
    
    const result = await mgcoinContract.stake(stakingAmount, {from: accounts[0]});
    const stakes = await mgcoinContract.getStakes({from: accounts[0]});
    
    // check staked event and 
    truffleAssert.eventEmitted(result, 'Staked', (ev) => {
      assert.equal(ev.account, accounts[0], "Stake address is not same");
      assert.equal(ev.amount, stakingAmount, "Staked amount is not same");
      return true;
    });

    // check stakes updated
    assert.equal(stakes.toNumber(), stakingAmount, 
        "Staked amount is not same");

    // check balance
    let balance = await mgcoinContract.balanceOf(accounts[0]);
    assert.equal(balance, initialBalance-stakingAmount, 
        "balance should reduce after staking");
    
    initialBalance -= stakingAmount;
  
    });

  // Assert fail
  it ('withdraw 25% stakes before one week', async() => {
    const withdrawAmount = 0.25 * stakingAmount;
    
    // expecting to revert
    await expectRevert(mgcoinContract.withraw(withdrawAmount, {from: accounts[0]}), 
        "cannot withdraw before one week");
  })

  it ('withdraw 25% stakes after 1 week', async() => {
    
    const withdrawAmount = 0.25 * stakingAmount;

    await time.increase(time.duration.weeks(2));
    
    const result = await mgcoinContract.withraw(withdrawAmount, {from: accounts[0]})
    const stakes = await mgcoinContract.getStakes({from: accounts[0]});

    // check Withdraw event
    truffleAssert.eventEmitted(result, 'Withdraw', (ev) => {
      assert.equal(ev.account, accounts[0], "Withdraw address is not same");
      assert.equal(ev.amount, withdrawAmount, "Withdraw amount is not same");
      return true;
    });

    // check stakes updated
    assert.equal(stakes.toNumber(), stakingAmount - withdrawAmount, 
        "Staked amount is not same");

    // check balance
    let balance = await mgcoinContract.balanceOf(accounts[0]);
    assert.equal(balance, initialBalance + withdrawAmount, 
        "balance should be updated");

    initialBalance += withdrawAmount;

  })

  // Assert fail
  it ('Reward before 1 month', async() => {
    // expecting to revert
    await expectRevert(mgcoinContract.reward({from: accounts[0]}), 
        "cannot reward before one month");
  })

  it ('Reward after 1 month', async() => {
    
    await time.increase(time.duration.days(29));
    
    const result = await mgcoinContract.reward({from: accounts[0]})
    const stakes = await mgcoinContract.getStakes({from: accounts[0]});

    let rewardAmount =  0.1 * stakes;
    // check Reward event
    truffleAssert.eventEmitted(result, 'Reward', (ev) => {
      assert.equal(ev.account, accounts[0], "Reward address is not same");
      assert.equal(ev.amount, rewardAmount, "Reward amount is not same");
      return true;
    });

    // check balance
    let balance = await mgcoinContract.balanceOf(accounts[0]);
    assert.equal(balance, initialBalance + rewardAmount,
        "balance should be updated");
        initialBalance += rewardAmount;
  })

  it ('Airdrop', async() => {        
      await mgcoinContract.airdrop(accounts[1]);
      let balance = await mgcoinContract.balanceOf(accounts[1]);
      assert.equal(balance.toNumber(), 1, 'airdrop not received');
  })

  // Assert fail
  it ('Airdrop on the same day', async() => {        
    // expecting to revert
    await expectRevert(mgcoinContract.airdrop(accounts[1]), "invalid drop");
})

//   it ('Reward after 60 months', async() => {
//     // 60 months in weeks
//     await time.increase(time.duration.weeks(236));
    
//     const result = await mgcoinContract.reward({from: accounts[0]})

//     var rewardAmount
//     // check Reward event
//     truffleAssert.eventEmitted(result, 'Reward', (ev) => {
//         assert.equal(ev.account, accounts[0], "Reward address is not same");
//         rewardAmount = ev.amount.toNumber();
//         return true;
//       });

//       let balance = await mgcoinContract.balanceOf(accounts[0]);
//       assert.equal(balance, initialBalance+rewardAmount, "reward amount credited");
//   });

//   // Assert fail
//   it ('Reward after max achieved', async() => {
//     // expecting to revert
//     await expectRevert(mgcoinContract.reward({from: accounts[0]}), 
//         "reward period is over");
//   });



});