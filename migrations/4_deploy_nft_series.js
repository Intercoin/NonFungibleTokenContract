const BokkyPooBahsRedBlackTreeLibrary = artifacts.require("./lib/BokkyPooBahsRedBlackTreeLibrary.sol");
const LibCommunity = artifacts.require("./lib/LibCommunity.sol");
const NFTSeries = artifacts.require("./NFTSeries.sol");
const NFTSeriesFactory = artifacts.require("./NFTSeriesFactory.sol");

module.exports = async(deployer) => {
    
    await deployer.link(BokkyPooBahsRedBlackTreeLibrary, NFTSeries);
    await deployer.link(LibCommunity, NFTSeries);
  
    await deployer.deploy(NFTSeries);
    let nftInstance = await NFTSeries.deployed();
    
    await deployer.deploy(NFTSeriesFactory);
    let factory = await NFTSeriesFactory.deployed();
    await factory.init(nftInstance.address);
};