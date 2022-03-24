# RDCoin

ERC20 = Total Supply 1.5 Billion RD Coins

### Staking contract requirements:

1. 10 percent of the total supply of RDC will be allocated for staking so 150,000,000 million rdc
2. Staked RDC tokens are not liquid and may not be transferred or sold . 
3. Staked RDC tokens may be unstaked over a period of four weeks, with 25% of the total amount of tokens being unstaked becoming available as liquid RDC tokens at the end of each of the four weeks from when the unstaking operation is submitted. 
4. The stake reward vesting should last 60 months for the 10 percent allocation.

---

### Airdrop contract requirements:

1. 5 percent of the total supply of RDC will be allocated for airdrop so 75,000,000 million rdc.
2. Rather than have a specific airdrop date and time, RDC tokens will be airdropped to asset holders when new transactions occur at RD Land daily over 1 year. Therefore every early holder can earn RDC airdrop with every transaction, including their own, within the RD Land ecosystem.
3. The airdrop reward vesting should last 12 months for the 5 percent allocation.

### Working

- Create a truffle project

    `truffle init`


- Place the RDCoin.sol file in the contracts folder
- Changed the solidity version to pragma in `truffle-config.js`
- Compile the contract

    `truffle compile`