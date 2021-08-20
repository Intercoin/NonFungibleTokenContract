const CoAuthors = artifacts.require("./lib/CoAuthors.sol");
const BokkyPooBahsRedBlackTreeLibrary = artifacts.require("./lib/BokkyPooBahsRedBlackTreeLibrary.sol");
const NFT = artifacts.require("./NFT.sol");
const NFTFactory = artifacts.require("./NFTFactory.sol");

module.exports = async(deployer) => {
    
    await deployer.link(CoAuthors, NFT);
    await deployer.link(BokkyPooBahsRedBlackTreeLibrary, NFT);
  
    await deployer.deploy(NFT);
    let nftInstance = await NFT.deployed();
    
    await deployer.deploy(NFTFactory);
    let factory = await NFTFactory.deployed();
    await factory.init(nftInstance.address);
};
