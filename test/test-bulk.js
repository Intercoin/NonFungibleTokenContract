const { ethers} = require('hardhat');
const { expect } = require('chai');
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

require("@nomicfoundation/hardhat-chai-matchers");

const { 
    deployNFT
} = require("./fixtures/deploy.js");

describe("Bulk tests", function () {
  
  it("should correct Bulk Sale", async() => {

    const res = await loadFixture(deployNFT);
    const {
      owner,
      alice,
      bob,
      charlie,
      price,
      seriesId,
      nft
    } = res;
    const NFTBulkSaleFactory = await ethers.getContractFactory("NFTBulkSaleV2");
    const nftBulkSale = await NFTBulkSaleFactory.deploy();

    const tokenId1 = 1n;
    const tokenId2 = 10n;
    const tokenId3 = 100n;
    const id1 = seriesId * (2n ** 192n) + tokenId1;
    const id2 = seriesId * (2n ** 192n) + tokenId2;
    const id3 = seriesId * (2n ** 192n) + tokenId3;

    const ids = [id1, id2, id3];
    const users = [
      alice.address,
      bob.address,
      charlie.address
    ];

    // try to distribte without setForwarder before
    await expect(
        nftBulkSale.connect(charlie).distribute(nft.target, ids, users, {value: price * 3n})
    ).to.be.revertedWithCustomError(nft, "CantManageThisSeries");

    expect(await nft.balanceOf(alice.address)).to.be.equal(0n);
    expect(await nft.balanceOf(bob.address)).to.be.equal(0n);
    expect(await nft.balanceOf(charlie.address)).to.be.equal(0n);


    await nft.connect(owner).setTrustedForwarder(nftBulkSale.target);
    await nftBulkSale.connect(charlie).distribute(nft.target, ids, users, {value: price * 3n});  

    //await nft.connect(owner).mintAndDistribute(ids, users);

    expect(await nft.balanceOf(alice.address)).to.be.equal(1n);
    expect(await nft.balanceOf(bob.address)).to.be.equal(1n);
    expect(await nft.balanceOf(charlie.address)).to.be.equal(1n);

    expect(await nft.ownerOf(id1)).to.be.equal(alice.address);
    expect(await nft.ownerOf(id2)).to.be.equal(bob.address);
    expect(await nft.ownerOf(id3)).to.be.equal(charlie.address);

  });

});
