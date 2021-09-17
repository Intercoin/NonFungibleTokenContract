const BokkyPooBahsRedBlackTreeLibrary = artifacts.require("./lib/BokkyPooBahsRedBlackTreeLibrary.sol");
const LibCommunity = artifacts.require("./lib/LibCommunity.sol");

module.exports = function(deployer) {
  deployer.deploy(BokkyPooBahsRedBlackTreeLibrary);
  deployer.deploy(LibCommunity);
  
};