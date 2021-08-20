const CoAuthors = artifacts.require("./lib/CoAuthors.sol");
const BokkyPooBahsRedBlackTreeLibrary = artifacts.require("./lib/BokkyPooBahsRedBlackTreeLibrary.sol");


module.exports = function(deployer) {
  deployer.deploy(CoAuthors);
  deployer.deploy(BokkyPooBahsRedBlackTreeLibrary);
  
};