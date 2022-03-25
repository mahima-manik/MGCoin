const { expect } = require("chai");
const { ethers } = require("hardhat");

describe('test token contract', async function () {
  let Token, token;
  before(async function () {
    Token = await ethers.getContractFactory('RDCoin');
    token = await Token.deploy();
    await token.deployed();
  });

   it('Should return the correct name and symbol', async function () {
     expect(await token.name()).to.equal('RDCoin');
     expect(await token.symbol()).to.equal('RDC');
   });

  it('Should return the correct balance the deployer address', async function () {
    const signers = await ethers.getSigners();
   
    const deployerAdd = signers[0].address;
    expect(await token.balanceOf(deployerAdd)).to.equal('1500000000000000000000000000');
  });
  
  it('test for total supply', async function () {
    
    expect(await token.totalSupply()).to.equal('1500000000000000000000000000');
  });

  it('test for approve function', async function () {
    const signers = await ethers.getSigners();
    const deployerAdd = signers[0]
    const deployerAdd_ = signers[0].address;
    const address2 = signers[1].address;
    const tx1 = await token.connect(deployerAdd).approve(address2, '1000000000000000000000000')
    expect(await token.allowance(deployerAdd_, address2)).to.equal('1000000000000000000000000');
  });

  it('test for transfer function', async function () {
    const signers = await ethers.getSigners();
    const deployerAdd = signers[0]
    const deployerAdd_ = signers[0].address;
    const address2 = signers[1].address;
    const tx1 = await token.connect(deployerAdd).transfer(address2,'1000000000000000000000000')
    expect(await token.balanceOf(address2)).to.equal('1000000000000000000000000');

  });

  it('test for transfer function', async function () {
    const signers = await ethers.getSigners();
    const deployerAdd = signers[0]
    const deployerAdd_ = signers[0].address;
    const address2_ = signers[1];
    const address2 = signers[1].address;
    const address3 = signers[2].address;
    const tx1 = await token.connect(deployerAdd).approve(address2, '1000000000000000000000000')
    await token.connect(address2_).transferFrom(deployerAdd_,address3,'1000000000000000000000000')
    
  
    expect(await token.balanceOf(address3)).to.equal('1000000000000000000000000');
    
  });
});

describe ("test staking contract", async function () {

  let Staking, staking;

  before(async function () {
    Staking = await ethers.getContractFactory('StakingRewards');
    staking = await Staking.deploy();
    await staking.deployed();
  });

  it('Should stake only rdcoin', async function () {
    const signers = await ethers.getSigners(); 
  });

  it('Should unstake only rdcoin', async function () {
    const signers = await ethers.getSigners();
  });

  it('Should calculate rdcoin rewards', async function () {
    const signers = await ethers.getSigners();
  });

  it('Should lock rdcoin stake for 4 weeks', async function () {
    const signers = await ethers.getSigners();
  });

  it('Should unstake only 25 percent every 4 weeks from total amount staked', async function () {
    const signers = await ethers.getSigners();
  });
  
  it('Should stake rdcoin at 10 percent yield from the stake allocation of 10 percent of th total supply', async function () {
    const signers = await ethers.getSigners();
  });

});
