const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';


const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const SERIES_BITS = 192;

chai.use(require('chai-bignumber')());


describe("ERC721UpgradeableExt test", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    beforeEach("deploying", async() => {
        const ERC20Factory = await ethers.getContractFactory("MockERC20");
        const NFTFactory = await ethers.getContractFactory("ERC721UpgradeableExt");
        this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
        this.nft = await NFTFactory.deploy();
        await this.nft.connect(owner).initialize();

        await this.erc20.mint(owner.address, TOTALSUPPLY);

        await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
    })


  it("should correct mint NFT with ETH if ID doesn't exist", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "";
    const params = [
      owner.address, 
      ZERO_ADDRESS, 
      price, 
      now + 100000, 
      baseURI,
      10000
    ];
    await this.nft.connect(owner).setSeriesInfo(seriesId, params);
    await this.nft.connect(alice)["buy(uint256)"](id, {value: price});
    const newOwner = await this.nft.ownerOf(id);
    expect(newOwner).to.be.equal(alice.address);
  });

  // xit("should correct mint NFT with token if ID doesn't exist", async() => {
  //   const seriesId = BigNumber.from('1000');
  //   const tokenId = ONE;
  //   const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);  // id = seriesId << 192 + tokenId
  //   const price = ethers.utils.parseEther('1');
  //   await this.erc20.connect(alice).approve(this.nft.address, price);
  //   await this.nft.connect(alice)["buy(uint256,address,uint256)"](id, this.erc20.address, price);
    
  // });


});

// UNIT TESTS:
// balanceOf()
// ownerOf()
// setTokenInfo()
// setSeriesInfo()
// listOnSale

// USER CASES:
// Alice creates collection

