var contract = artifacts.require("./Auction.sol");

module.exports = function (deployer) {
  deployer.deploy(contract);
};
