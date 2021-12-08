const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';


const ZERO = BigNumber.from('0');
const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const THREE = BigNumber.from('3');
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
        await this.nft.connect(owner).initialize("NFT Edition", "NFT");

        await this.erc20.mint(owner.address, TOTALSUPPLY);

        await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(charlie.address, ethers.utils.parseEther('100'));
    })

  it("should correct put series on sale for Alice", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "someURI";
    const params = [
      alice.address, 
      ZERO_ADDRESS, 
      price, 
      now + 100000, 
      baseURI,
      10000
    ];
    await this.nft.connect(owner).setSeriesInfo(seriesId, params);
    const seriesInfo = await this.nft.getSeriesInfo(seriesId);
    expect(seriesInfo.owner).to.be.equal(alice.address);
    expect(seriesInfo.currency).to.be.equal(ZERO_ADDRESS);
    expect(seriesInfo.amount).to.be.equal(price);
    expect(seriesInfo.onSaleUntil).to.be.equal(now + 100000);
    expect(seriesInfo.baseURI).to.be.equal(baseURI);
    expect(seriesInfo.limit).to.be.equal(10000);

    expect(await this.nft.ownerOf(id)).to.be.equal(alice.address);

  })

  it("should correct put token on sale", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "someURI";
    
    const tokenParams = [
      alice.address, 
      ZERO_ADDRESS, 
      price, 
      now + 100000,
    ];
    const seriesParams = tokenParams.concat([baseURI, 10000]);

    await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
    await this.nft.connect(alice).setTokenInfo(id, tokenParams);
    const tokenInfo = await this.nft.getTokenInfo(id);
    expect(tokenInfo.owner).to.be.equal(alice.address);
    expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
    expect(tokenInfo.amount).to.be.equal(price);
    expect(tokenInfo.onSaleUntil).to.be.equal(now + 100000);

    expect(await this.nft.ownerOf(id)).to.be.equal(alice.address);


  })

  describe("buy tests", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "";
    const seriesParams = [
      alice.address,  
      ZERO_ADDRESS, 
      price, 
      now + 100000, 
      baseURI,
      10000
    ];
    beforeEach("listing series on sale", async() => {
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
    })
    it("should correct mint NFT with ETH if ID doesn't exist", async() => {
      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
      await this.nft.connect(bob)["buy(uint256)"](id, {value: price.mul(TWO)}); // accidentially send more than needed
      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
      expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
      expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);
      const seriesOwner = await this.nft.ownerOf(id.add(ONE));
      expect(seriesOwner).to.be.equal(alice.address);   // series owner is the same

      const tokenInfo = await this.nft.getTokenInfo(id);
      expect(tokenInfo.owner).to.be.equal(bob.address);
      expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfo.amount).to.be.equal(ZERO);
      expect(tokenInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.owner).to.be.equal(alice.address);
      expect(seriesInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.amount).to.be.equal(price);
      expect(seriesInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

  
    });
  
    it("should correct mint NFT with token if ID doesn't exist", async() => {
      const seriesParams = [
        alice.address, 
        this.erc20.address, 
        price, 
        now + 100000, 
        baseURI,
        10000
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(bob).approve(this.nft.address, price);
      const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
      const balanceBeforeAlice = await this.erc20.balanceOf(alice.address);
      await this.nft.connect(bob)["buy(uint256,address,uint256)"](id, this.erc20.address, price.mul(TWO)); // accidentially send more than needed
      const balanceAfterBob = await this.erc20.balanceOf(bob.address);
      const balanceAfterAlice = await this.erc20.balanceOf(alice.address);
      expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.equal(price);
      expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);
      const seriesOwner = await this.nft.ownerOf(id.add(ONE));
      expect(seriesOwner).to.be.equal(alice.address);   // series owner is the same

      
      const tokenInfo = await this.nft.getTokenInfo(id);
      expect(tokenInfo.owner).to.be.equal(bob.address);
      expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfo.amount).to.be.equal(ZERO);
      expect(tokenInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.owner).to.be.equal(alice.address);
      expect(seriesInfo.currency).to.be.equal(this.erc20.address);
      expect(seriesInfo.amount).to.be.equal(price);
      expect(seriesInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);


    });

    it("should correct buy minted NFT for ETH", async() => {
      await this.nft.connect(bob)["buy(uint256)"](id, {value: price});
      const tokenParams = [
        bob.address, 
        ZERO_ADDRESS, 
        price.mul(TWO), 
        now + 100000,
      ];      

      await this.nft.connect(bob).setTokenInfo(id, tokenParams);

      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);
      await this.nft.connect(charlie)["buy(uint256)"](id, {value: price.mul(THREE)}); // accidentially send more than needed
      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
      expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
      expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.gt(price.mul(TWO));

      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(charlie.address);

      const tokenInfo = await this.nft.getTokenInfo(id);
      expect(tokenInfo.owner).to.be.equal(charlie.address);
      expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfo.amount).to.be.equal(price.mul(TWO));
      expect(tokenInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.owner).to.be.equal(alice.address);
      expect(seriesInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.amount).to.be.equal(price);
      expect(seriesInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

    });

    it("should correct buy minted NFT for token", async() => {
      await this.nft.connect(bob)["buy(uint256)"](id, {value: price});
      const tokenParams = [
        bob.address, 
        this.erc20.address, 
        price.mul(TWO), 
        now + 100000,
      ];      

      await this.nft.connect(bob).setTokenInfo(id, tokenParams);

      const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
      const balanceBeforeCharlie = await this.erc20.balanceOf(charlie.address);
      await this.erc20.connect(charlie).approve(this.nft.address, price.mul(THREE));
      await this.nft.connect(charlie)["buy(uint256,address,uint256)"](id, this.erc20.address, price.mul(THREE)); // accidentially send more than needed
      const balanceAfterBob = await this.erc20.balanceOf(bob.address);
      const balanceAfterCharlie = await this.erc20.balanceOf(charlie.address);
      expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
      expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.equal(price.mul(TWO));

      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(charlie.address);

      const tokenInfo = await this.nft.getTokenInfo(id);
      expect(tokenInfo.owner).to.be.equal(charlie.address);
      expect(tokenInfo.currency).to.be.equal(this.erc20.address);
      expect(tokenInfo.amount).to.be.equal(price.mul(TWO));
      expect(tokenInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.owner).to.be.equal(alice.address);
      expect(seriesInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.amount).to.be.equal(price);
      expect(seriesInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

    });
    // TODO mint and list on sale for someBody

  })
  


});

// UNIT TESTS:
// balanceOf()
// ownerOf()
// setTokenInfo()
// setSeriesInfo()
// listOnSale

// USER CASES:
// Alice creates collection

