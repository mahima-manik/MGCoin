const Stakeable = artifacts.require("Stakeable");
const Airdrop = artifacts.require("Airdrop");
const MGCoin = artifacts.require("MGCoin");

module.exports = async function (deployer) {
  await deployer.deploy(Stakeable);
  await deployer.deploy(Airdrop);
  await deployer.deploy(MGCoin);
};
