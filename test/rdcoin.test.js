const Stakeable = artifacts.require("Stakeable");
const Airdrop = artifacts.require("Airdrop");
const RDCoin = artifacts.require("RDCoin");
const truffleAssert = require('truffle-assertions');
const { time } = require('@openzeppelin/test-helpers');
const { expectRevert } = require('@openzeppelin/test-helpers');

contract("RDCoin", (accounts) => {
  
  const stakingAmount = 1000;

  before(async () => {
    stakeContract = await Stakeable.deployed();
    airdropContract = await Airdrop.deployed();
    rdcoinContract = await RDCoin.deployed();
    initialBalance = await rdcoinContract.balanceOf(accounts[0]);
  });

  it ('Add stakes above MAX_ALLOWED_STAKES', async () => {
    const stakingAmount = 150000001;

    // expecting to revert
    truffleAssert.reverts(rdcoinContract.stake(stakingAmount, {from: accounts[0]}), 'total stakes exceeded 150000000');
  });

  it ('Add stakes', async () => {
    
    const result = await rdcoinContract.stake(stakingAmount, {from: accounts[0]});
    const stakes = await rdcoinContract.getStakes({from: accounts[0]});
    
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
    let balance = await rdcoinContract.balanceOf(accounts[0]);
    assert.equal(balance, initialBalance-stakingAmount, 
        "balance should reduce after staking");

  });

  it ('withdraw 25% stakes before one week', async() => {
    const withdrawAmount = 0.25 * stakingAmount;
    
    // expecting to revert
    await expectRevert(rdcoinContract.withraw(withdrawAmount, {from: accounts[0]}), 
        "cannot withdraw before one week");
  })

  it ('withdraw 25% stakes after 1 week', async() => {
    
    const withdrawAmount = 0.25 * stakingAmount;

    await time.increase(time.duration.weeks(1));
    
    const result = await rdcoinContract.withraw(withdrawAmount, {from: accounts[0]})
    const stakes = await rdcoinContract.getStakes({from: accounts[0]});

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
    let balance = await rdcoinContract.balanceOf(accounts[0]);
    assert.equal(balance, initialBalance-stakingAmount+withdrawAmount, 
        "balance should be updated");
  })

});