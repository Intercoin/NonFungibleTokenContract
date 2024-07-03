const { ethers} = require('hardhat');
const { expect } = require('chai');
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

require("@nomicfoundation/hardhat-chai-matchers");

const { 
    deployNFT
} = require("./fixtures/deploy.js");

const { 
    toHexString
} = require("./helpers/toHexString.js");

// const { ethers, waffle } = require('hardhat');
// const { BigNumber } = require('ethers');
// const { expect } = require('chai');
// const chai = require('chai');
// const { time } = require('@openzeppelin/test-helpers');

// const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
// const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
// const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';

// const contractURI = "https://contracturi";

// const 0n = BigNumber.from('0');
// const ONE = BigNumber.from('1');
// const 2n = BigNumber.from('2');
// const 3n = BigNumber.from('3');
// const 4n = BigNumber.from('4');
// const 5n = BigNumber.from('5');
// const 6n = BigNumber.from('6');
// const 7n = BigNumber.from('7');
// const TEN = BigNumber.from('10');
// const HUN = BigNumber.from('100');

// const ONE_ETH = ethers.utils.parseEther('1');    

// const SERIES_BITS = 192;
// const FRACTION = BigNumber.from('10000');

// const accounts = waffle.provider.getWallets();
// const owner = accounts[0];                     
// const alice = accounts[1];
// const bob = accounts[2];
// const charlie = accounts[3];
// const commissionReceiver = accounts[4];
// const frank = accounts[5];
// const buyer = accounts[6];


// chai.use(require('chai-bignumber')());


// const OPERATION_INITIALIZE = 0;
// const OPERATION_SETMETADATA = 1;
// const OPERATION_SETSERIESINFO = 2;
// const OPERATION_SETOWNERCOMMISSION = 3;
// const OPERATION_SETCOMMISSION = 4;
// const OPERATION_REMOVECOMMISSION = 5;
// const OPERATION_LISTFORSALE = 6;
// const OPERATION_REMOVEFROMSALE = 7;
// const OPERATION_MINTANDDISTRIBUTE = 8;
// const OPERATION_BURN = 9;
// const OPERATION_BUY = 10;
// const OPERATION_TRANSFER = 11;

describe("NonFungibleToken tests", function () {
/*
  describe("put series on sale", async() => {
    
    it("should correct for Alice", async() => {
      const res = await loadFixture(deployNFT);
      const {
          alice,
          seriesId,
          ZERO_ADDRESS,
          price,
          now,
          baseURI,
          nft
      } = res;
            

      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000n);
      
    });

    it("Alice can manage her series", async() => {
      const res = await loadFixture(deployNFT);
      const {
          alice,
          charlie,
          seriesId,
          nft
      } = res;

      let x = await nft.connect(charlie).canManageSeries(alice.address, seriesId);
      expect(x).to.be.true;
    });

    it("Bob can not manage Alice's series", async() => {
      const res = await loadFixture(deployNFT);
      const {
          bob,
          charlie,
          seriesId,
          nft
      } = res;

      let x = await nft.connect(charlie).canManageSeries(bob.address, seriesId);
      expect(x).to.be.false;
    });

  });

  describe("CostManager test", async() => {
  
    it("shouldnt override costmanager", async () => {

      const res = await loadFixture(deployNFT);
      const {
          bob,
          costManagerGood,
          nft
      } = res;
         
      await expect(
          nft.connect(bob).overrideCostManager(costManagerGood.target)
      ).to.be.revertedWith("cannot override");
      
    });     

    it("should override costmanager", async () => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        bob,
        costManagerGood,
        nft,
        nftFactory
      } = res;
         
      await expect(
        nft.connect(bob).overrideCostManager(costManagerGood.target)
      ).to.be.revertedWith("cannot override");

      let oldCostManager = await nft.costManager();
      // here should be an factory's owner
      await nftFactory.connect(owner).renounceOverrideCostManager(nft.target);
      // but here should be user
      await nft.connect(owner).overrideCostManager(costManagerGood.target);

      let newCostManager = await nft.costManager();

      expect(oldCostManager).not.to.be.eq(newCostManager);
      expect(newCostManager).to.be.eq(costManagerGood.target);

    }); 
    

  });
*/  


  describe("buy tests", async() => {

    it("should correct mint NFT with ETH if ID doesn't exist", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        now,
        baseURI,
        erc20,
        nft
      } = res;

      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price * 2n}); // accidentially send more than needed
      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
      expect(balanceBeforeBob-(balanceAfterBob)).to.be.gt(price);
      expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);

      const tokenInfoData = await nft.tokenInfo(id);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.ownerCommissionValue).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.authorCommissionValue).to.be.equal(0n);

      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000n);

      expect(await nft.mintedCountBySeries(seriesId)).to.be.equal(1n);

      //check getSeriesInfo
      const getSeriesInfoData = await nft.getSeriesInfo(seriesId);
      expect(getSeriesInfoData.author).to.be.equal(alice.address);
      expect(getSeriesInfoData.currency).to.be.equal(ZERO_ADDRESS);
      expect(getSeriesInfoData.price).to.be.equal(price);
      expect(getSeriesInfoData.onSaleUntil).to.be.equal(now + 100000n);
      expect(getSeriesInfoData.baseURI).to.be.equal(baseURI);
      expect(getSeriesInfoData.limit).to.be.equal(10000n);
    });

    it("should correct mint NFT with token if ID doesn't exist", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        now,
        baseURI,
        suffix,
        commissions, 
        erc20,
        nft
      } = res;

      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address, 
        10000n,
        saleParams,
        commissions, 
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await erc20.connect(bob).approve(nft.target, price);
      const balanceBeforeBob = await erc20.balanceOf(bob.address);
      const balanceBeforeAlice = await erc20.balanceOf(alice.address);
      await nft.connect(bob).buy([id], erc20.target, price * 2n, false, 0n, bob.address); // accidentially send more than needed
      const balanceAfterBob = await erc20.balanceOf(bob.address);
      const balanceAfterAlice = await erc20.balanceOf(alice.address);
      expect(balanceBeforeBob-(balanceAfterBob)).to.be.equal(price);
      expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);
      
      const tokenInfoData = await nft.tokenInfo(id);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.ownerCommissionValue).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.authorCommissionValue).to.be.equal(0n);

      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(erc20.target);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000n);

      expect(await nft.mintedCountBySeries(seriesId)).to.be.equal(1n);

    });

    it("should correct buy minted NFT for ETH", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        //saleParams,
        now,
        baseURI,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const saleParams = [
        now + 100000n,
        ZERO_ADDRESS, 
        price * 2n,
        0n //autoincrement price
      ];      

      //await nft.connect(bob).setSaleInfo(id, saleParams);

      await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);

      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);

      await nft.connect(charlie).buy([id], ZERO_ADDRESS, price * 2n, false, 0n, charlie.address, {value: price * 3n}); // accidentially send more than needed

      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
      expect(balanceAfterBob-(balanceBeforeBob)).to.be.equal(price * 2n);
      expect(balanceBeforeCharlie-(balanceAfterCharlie)).to.be.gt(price * 2n);

      const newOwner = await nft.ownerOf(id);

      expect(newOwner).to.be.equal(charlie.address);

      const tokenInfoData = await nft.tokenInfo(id);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(price * 2n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.ownerCommissionValue).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.authorCommissionValue).to.be.equal(0n);
      // check the same but for method series
      expect(tokenInfoData.seriesInfo.author).to.be.equal(alice.address);
      expect(tokenInfoData.seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(tokenInfoData.seriesInfo.saleInfo.price).to.be.equal(price);
      expect(tokenInfoData.seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(tokenInfoData.seriesInfo.baseURI).to.be.equal(baseURI);
      expect(tokenInfoData.seriesInfo.limit).to.be.equal(10000n);

      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000n);

      
    });
 
    it("should correct mint NFT with ETH using autoincrement", async() => {
      const res = await loadFixture(deployNFT);
      const {
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        seriesParams,
        now,
        baseURI,
        erc20,
        nft
      } = res;


      const expectedTokens = [
        seriesId * (2n ** 192n) + (0n),
        seriesId * (2n ** 192n) + (1n),
        seriesId * (2n ** 192n) + (2n)
      ];
      let owner;
      let tokenSaleInfo;

      for(let i in expectedTokens) {

        await expect(nft.ownerOf(expectedTokens[i])).to.be.revertedWith("ERC721: owner query for nonexistent token");

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(seriesParams[0]);
        expect(tokenSaleInfo.exists).to.be.false;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(seriesParams[2][2]);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(seriesParams[2][0]);
        
      };

      // buy three tokens in seriesId
      // expect tokens like XX00001,XX00002,XX00003
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256)"](seriesId, price, false, 0n, {value: price * 2n}); // accidentially send more than needed
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256)"](seriesId, price, false, 0n, {value: price * 2n}); // accidentially send more than needed
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256)"](seriesId, price, false, 0n, {value: price * 2n}); // accidentially send more than needed

      for(let i in expectedTokens) {
        owner = await nft.ownerOf(expectedTokens[i]);
        expect(owner).to.be.equal(bob.address);

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(bob.address);
        expect(tokenSaleInfo.exists).to.be.true;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(0n);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(0n);
        
      };


    });

    it("should correct mint NFT with token using autoincrement", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      
      const expectedTokens = [
        seriesId * (2n ** 192n)+(0n),
        seriesId * (2n ** 192n)+(1n),
        seriesId * (2n ** 192n)+(2n)
      ];
      

      
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address, 
        10000n,
        saleParams,
        commissions, 
        baseURI,
        suffix
      ];

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

      let tokenOwner;
      let tokenSaleInfo;

      for(let i in expectedTokens) {

        await expect(nft.ownerOf(expectedTokens[i])).to.be.revertedWith("ERC721: owner query for nonexistent token");

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(seriesParams[0]);
        expect(tokenSaleInfo.exists).to.be.false;

        expect(tokenSaleInfo.data.currency).to.be.equal(seriesParams[2][1]);
        expect(tokenSaleInfo.data.price).to.be.equal(seriesParams[2][2]);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(seriesParams[2][0]);
        
      };


      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed

      for(let i in expectedTokens) {
        tokenOwner = await nft.ownerOf(expectedTokens[i]);
        expect(tokenOwner).to.be.equal(bob.address);

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(bob.address);
        expect(tokenSaleInfo.exists).to.be.true;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(0n);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(0n);
        
      };

    });

    it("should correct mint NFT with token using autoincrement price", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      
      const expectedTokens = [
        seriesId * (2n ** 192n)+(0n),
        seriesId * (2n ** 192n)+(1n),
        seriesId * (2n ** 192n)+(2n)
      ];
      
      const expectedToken2 = seriesId * (2n ** 192n)+(3n);

      const expectedTokens3 = [
        seriesId * (2n ** 192n)+(4n),
        seriesId * (2n ** 192n)+(5n),
        seriesId * (2n ** 192n)+(6n)
      ];
      const expectedToken4 = seriesId * (2n ** 192n)+(7n);

      const autoincrementPrice = ethers.parseEther('0.01');
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        autoincrementPrice
      ];
      const seriesParams = [
        alice.address, 
        10000n,
        saleParams,
        commissions, 
        baseURI,
        suffix
      ];

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

      let tokenOwner;
      let tokenSaleInfo;

      for(let i in expectedTokens) {

        await expect(nft.ownerOf(expectedTokens[i])).to.be.revertedWith("ERC721: owner query for nonexistent token");

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(seriesParams[0]);
        expect(tokenSaleInfo.exists).to.be.false;

        expect(tokenSaleInfo.data.currency).to.be.equal(seriesParams[2][1]);
        expect(tokenSaleInfo.data.price).to.be.equal(seriesParams[2][2]);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(seriesParams[2][0]);
        
      };


      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed

      for(let i in expectedTokens) {
        tokenOwner = await nft.ownerOf(expectedTokens[i]);
        expect(tokenOwner).to.be.equal(bob.address);

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(bob.address);
        expect(tokenSaleInfo.exists).to.be.true;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(0n);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(0n);
        
      };
      
      
      ////////////
      tokenSaleInfo = await nft.getTokenSaleInfo(expectedToken2);
      expect(tokenSaleInfo.data.price).to.be.equal(
        price+(
          [...Array(expectedTokens.length).keys()].map((e,i)=>autoincrementPrice * BigInt(i)).reduce((a, b) => BigInt(b)+BigInt(a), 0)
        )
      );

      await expect(
        nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price, false, 0n)
      ).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');

      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed

      // setup again. we will expect that autoincrement value will drop
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price * 2n);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](seriesId, erc20.target, price * 2n, false, 0n); // accidentially send more than needed

      let calculatePrice = price;
      await erc20.connect(bob).approve(nft.target, calculatePrice);
      await expect(
        nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](
          seriesId, 
          erc20.target, 
          calculatePrice, 
          false, 
          0n
        )
      ).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');

      // length -1
      calculatePrice = price+(
        [...(Array(expectedTokens3.length-1).keys())].map((e,i)=>autoincrementPrice * BigInt(i)).reduce((a, b) => BigInt(b)+BigInt(a), 0)
      );
      await erc20.connect(bob).approve(nft.target, calculatePrice);    
      await expect(
        nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](
          seriesId, 
          erc20.target, 
          calculatePrice, 
          false, 
          0n
        )
      ).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');

      // send exactle that needed
      calculatePrice = price+(
        [...Array(expectedTokens3.length).keys()].map((e,i)=>autoincrementPrice * BigInt(i)).reduce((a, b) => BigInt(b)+BigInt(a), 0)
      );
      await erc20.connect(bob).approve(nft.target, calculatePrice);    
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256)"](
        seriesId, 
        erc20.target, 
        calculatePrice, 
        false, 
        0n
      ); 
    });

    /////////////////////////////////////////////
    
    it("should correct mint NFT with ETH using autoincrement(with buyFor option)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        seriesParams,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      const expectedTokens = [
        seriesId * (2n ** 192n)+(0n),
        seriesId * (2n ** 192n)+(1n),
        seriesId * (2n ** 192n)+(2n)
      ];

      let owner;
      let tokenSaleInfo;

      for( let i in expectedTokens) {

        await expect(nft.ownerOf(expectedTokens[i])).to.be.revertedWith("ERC721: owner query for nonexistent token");

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(seriesParams[0]); // Series owner
        expect(tokenSaleInfo.exists).to.be.false;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(seriesParams[2][2]);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(seriesParams[2][0]);
        
      };

      // buy three tokens in seriesId
      // expect tokens like XX00001,XX00002,XX00003
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256,address)"](seriesId, price, false, 0n, charlie.address, {value: price * 2n}); // accidentially send more than needed
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256,address)"](seriesId, price, false, 0n, charlie.address, {value: price * 2n}); // accidentially send more than needed
      await nft.connect(bob)["buyAuto(uint64,uint256,bool,uint256,address)"](seriesId, price, false, 0n, charlie.address, {value: price * 2n}); // accidentially send more than needed

      for(let i in expectedTokens) {
        owner = await nft.ownerOf(expectedTokens[i]);

        expect(owner).to.be.equal(charlie.address);

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(charlie.address);
        expect(tokenSaleInfo.exists).to.be.true;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(0n);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(0n);
        
      };


    });

    it("should correct mint NFT with token using autoincrement(with buyFor option)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      const expectedTokens = [
        seriesId * (2n ** 192n)+(0n),
        seriesId * (2n ** 192n)+(1n),
        seriesId * (2n ** 192n)+(2n)
      ];
      
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address, 
        10000n,
        saleParams,
        commissions, 
        baseURI,
        suffix
      ];

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

      let tokenOwner;
      let tokenSaleInfo;

      for(let i in expectedTokens) {

        await expect(nft.ownerOf(expectedTokens[i])).to.be.revertedWith("ERC721: owner query for nonexistent token");

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(seriesParams[0]);
        expect(tokenSaleInfo.exists).to.be.false;

        expect(tokenSaleInfo.data.currency).to.be.equal(seriesParams[2][1]);
        expect(tokenSaleInfo.data.price).to.be.equal(seriesParams[2][2]);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(seriesParams[2][0]);
        
      };


      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256,address)"](seriesId, erc20.target, price * 2n, false, 0n, charlie.address); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256,address)"](seriesId, erc20.target, price * 2n, false, 0n, charlie.address); // accidentially send more than needed
      await erc20.connect(bob).approve(nft.target, price);
      await nft.connect(bob)["buyAuto(uint64,address,uint256,bool,uint256,address)"](seriesId, erc20.target, price * 2n, false, 0n, charlie.address); // accidentially send more than needed

      for(let i in expectedTokens) {
        tokenOwner = await nft.ownerOf(expectedTokens[i]);
        expect(tokenOwner).to.be.equal(charlie.address);

        tokenSaleInfo = await nft.getTokenSaleInfo(expectedTokens[i]);

        expect(tokenSaleInfo.owner).to.be.equal(charlie.address);
        expect(tokenSaleInfo.exists).to.be.true;

        expect(tokenSaleInfo.data.currency).to.be.equal(ZERO_ADDRESS);
        expect(tokenSaleInfo.data.price).to.be.equal(0n);
        expect(tokenSaleInfo.data.onSaleUntil).to.be.equal(0n);
        
      };

    });

    it("should correct buy minted NFT for token", async() => {
      const res = await loadFixture(deployNFT);
      const {
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const saleParams = [
        now + 100000n,
        erc20.target, 
        price * 2n,
        0n //autoincrement price
      ];      

      //await nft.connect(bob).setSaleInfo(id, saleParams);
      await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);

      const balanceBeforeBob = await erc20.balanceOf(bob.address);
      const balanceBeforeCharlie = await erc20.balanceOf(charlie.address);
      await erc20.connect(charlie).approve(nft.target, price * 3n);
      await nft.connect(charlie).buy([id], erc20.target, price * 3n, false, 0n, charlie.address); // accidentially send more than needed
      const balanceAfterBob = await erc20.balanceOf(bob.address);
      const balanceAfterCharlie = await erc20.balanceOf(charlie.address);
      expect(balanceAfterBob-(balanceBeforeBob)).to.be.equal(price * 2n);
      expect(balanceBeforeCharlie-(balanceAfterCharlie)).to.be.equal(price * 2n);

      const newOwner = await nft.ownerOf(id);
      expect(newOwner).to.be.equal(charlie.address);

      const tokenInfoData = await nft.tokenInfo(id);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(erc20.target);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(price * 2n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.ownerCommissionValue).to.be.equal(0n);
      expect(tokenInfoData.tokenInfo.salesInfoToken.authorCommissionValue).to.be.equal(0n);

      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000n);

    });

    it("should correct mint NFT from own series", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await erc20.connect(alice).approve(nft.target, price);
      await nft.connect(alice).buy([id], erc20.target, price, false, 0n, alice.address); 
    });

    it("shouldnt buy if token was burned (ETH)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        DEAD_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
      await expect(nft.connect(charlie).buy([id], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    });
  
    it("should correct set metadata", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      const newBaseURI = "https://newBaseURI/";
      const newSuffix = "newSuffix";
      const newContractURI = "newContractURI";
      await nft.setBaseURI(newBaseURI);
      expect(await nft.baseURI()).to.be.equal(newBaseURI);
      await nft.setSuffix(newSuffix);
      expect(await nft.suffix()).to.be.equal(newSuffix);
      await nft.setContractURI(newContractURI);
      expect(await nft.contractURI()).to.be.equal(newContractURI);

    });

    it("shouldnt buy if token was burned (token)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        DEAD_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});

      const saleParams = [
        now + 100000n,
        ZERO_ADDRESS, 
        price,
        0n //autoincrement price
      ];      

      //await nft.connect(bob).setSaleInfo(id, saleParams);
      await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);

      await nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);

      await expect(nft.connect(charlie).buy([id], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    })

    it("shouldnt buy if token has another currency(if not on sale)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        DEAD_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
      await erc20.connect(charlie).approve(nft.target, price);
      await expect(nft.connect(charlie).buy([id], erc20.target, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    })

    it("shouldnt buy if token wasnt listed on sale", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await expect(nft.connect(charlie).buy([id], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    })

    it("shouldnt buy if token was removed from sale", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const saleParams = [
        now + 100000n,
        ZERO_ADDRESS, 
        price * 2n,
        0n //autoincrement price
      ];      

      await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
      await nft.connect(bob).removeFromSale(id);
      await expect(nft.connect(charlie).buy([id], ZERO_ADDRESS, price * 2n, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    })

    it("shouldnt mint if series was unlisted from sale", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      const saleParams = [
        0n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price})).to.be.revertedWithCustomError(nft, 'TokenIsNotOnSale');
    })

    it("shouldnt buy if user passed unsufficient ETH", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        ZERO_ADDRESS,
        DEAD_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;

      await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price-(1n)})).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');
    })
    // deprecated 
    // it("shouldnt set token info if not owner", async() => {   
    //   const saleParams = [
    //     now + 100000n,
    //     ZERO_ADDRESS, 
    //     price * 2n,
    //     0n, //ownerCommissionValue;
    //     0n  //authorCommissionValue;
    //   ];   
    //   await expect(nft.connect(charlie).listForSale(id, saleParams[2], saleParams[1], saleParams[0])).to.be.revertedWith("!onlyTokenOwnerAuthorOrOperator");
    // })

    it("shouldnt buy if user approved unsufficient token amount", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        charlie,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];       
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await erc20.connect(charlie).approve(nft.target, price-(1n));
      await expect(nft.connect(charlie).buy([id], erc20.target, price, false, 0n, charlie.address)).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');
    })

    it("shouldnt buy if user passed unsufficient token amount", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        charlie,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      

      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await erc20.connect(charlie).approve(nft.target, price);
      await expect(nft.connect(charlie).buy([id], erc20.target, price-(1n), false, 0n, charlie.address)).to.be.revertedWithCustomError(nft, 'InsufficientAmountSent');
    })

    it("shouldnt buy if token is invalid", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await erc20.connect(charlie).approve(nft.target, price);
      const wrongAddress = bob.address;
      await expect(nft.connect(charlie).buy([id], wrongAddress, price, false, 0n, charlie.address)).to.be.revertedWithCustomError(nft, 'CurrencyInvalid');
    })

    it("should correct list on sale via listForSale", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        ZERO_ADDRESS,
        id,
        price,
        erc20,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const duration = 1000n;
      const newPrice = price * 2n;
      const newCurrency = erc20.target;
      await nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);

      const tokenInfoData = await nft.tokenInfo(id);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(newCurrency);
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(newPrice);
      const lastTs = await time.latest();
      expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(BigInt(lastTs) + duration);

    })

    it("shouldnt list on sale via listForSale if already listed", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        ZERO_ADDRESS,
        id,
        price,
        erc20,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const duration = 1000n;
      const newPrice = price * 2n;
      const newCurrency = erc20.target;
      
      await nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);
      
      await expect(nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWithCustomError(nft, 'AlreadyInSale');
      

    })

    it("shouldnt list on sale via listForSale if not owner", async() => {
      const res = await loadFixture(deployNFT);
      const {
        alice,
        bob,
        ZERO_ADDRESS,
        id,
        price,
        erc20,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const duration = 1000n;
      const newPrice = price * 2n;
      const newCurrency = erc20.target;
      await expect(nft.connect(alice).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWithCustomError(nft, 'CantManageThisToken');

    })

    it("shouldnt list on sale via listForSale if duration is invalid", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        ZERO_ADDRESS,
        id,
        price,
        erc20,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const duration = 0;
      const newPrice = price * 2n;
      const newCurrency = erc20.target;
      await expect(nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWithCustomError(nft, 'DurationInvalid');

    })

    it("shouldnt buy burnt token", async() => {const res = await loadFixture(deployNFT);
      const {
        bob,
        charlie,
        ZERO_ADDRESS,
        id,
        price,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).burn(id);
      await expect(nft.connect(charlie).buy([id], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError( nft, 'TokenIsNotOnSale');
    })

    it("should mint tokens for several users via mintAndDistribute", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        charlie,
        nft
      } = res;
      
      const series1Id = 1000n;
      const series2Id = 1005n;
      const tokenId1 = 1n;
      const tokenId2 = 10n;
      const tokenId3 = 100n;
      const id1 = series1Id * (2n ** 192n)+(tokenId1);
      const id2 = series2Id * (2n ** 192n)+(tokenId2);
      const id3 = series2Id * (2n ** 192n)+(tokenId3);
  
      const ids = [id1, id2, id3];
      const users = [
        alice.address,
        bob.address,
        charlie.address
      ]
      await nft.connect(owner).mintAndDistribute(ids, users);
      expect(await nft.balanceOf(alice.address)).to.be.equal(1n);
      expect(await nft.balanceOf(bob.address)).to.be.equal(1n);
      expect(await nft.balanceOf(charlie.address)).to.be.equal(1n);

      expect(await nft.ownerOf(id1)).to.be.equal(alice.address);
      expect(await nft.ownerOf(id2)).to.be.equal(bob.address);
      expect(await nft.ownerOf(id3)).to.be.equal(charlie.address);
            
    })

    it("shouldnt mint tokens via mintAndDistribute if lengths are not the same ", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        nft
      } = res;
      
      const ids = [1, 2, 3];
      const wrongLengthAddresses = [
        alice.address,
        bob.address
      ]

      await expect(nft.connect(owner).mintAndDistribute(ids, wrongLengthAddresses)).to.be.revertedWithCustomError(nft, 'LengthsShouldBeTheSame');

    })
    

    it("should mint tokens via mintAndDistributeAuto by seriesId", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        nft
      } = res;

      const seriesId = 1009n;
      const expectedTokens = [
        seriesId * (2n ** 192n)+(0n),
        seriesId * (2n ** 192n)+(1n),
        seriesId * (2n ** 192n)+(2n)
      ];

      await nft.connect(owner).mintAndDistributeAuto(seriesId, alice.address, 3n);

      expect(await nft.balanceOf(alice.address)).to.be.equal(3n);

      expect(await nft.ownerOf(expectedTokens[0])).to.be.equal(alice.address);
      expect(await nft.ownerOf(expectedTokens[1])).to.be.equal(alice.address);
      expect(await nft.ownerOf(expectedTokens[2])).to.be.equal(alice.address);

    })

    it("should correct call setSeriesInfo as an owner of series", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        ZERO_ADDRESS,
        seriesId,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        nft
      } = res;
      
      const newLimit = 11000;
      const saleParams = [
        now + 100000n, 
        ZERO_ADDRESS, 
        price,
        0n //autoincrement price
      ]
      const newParams = [
        alice.address,  
        newLimit,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, newParams);
      const seriesInfo = await nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(newLimit);
  
    })

    it("shouldnt buy if limit exceeded", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        charlie,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        nft
      } = res;
      
      const newLimit = 2n;
      const saleParams = [
        now + 100000n, 
        ZERO_ADDRESS, 
        price,
        0n //autoincrement price
      ]
      const newParams = [
        alice.address,  
        newLimit,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, newParams);
      await nft.connect(charlie).buy([id], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price});
      await nft.connect(charlie).buy([id+(1n)], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price});
      await expect(nft.connect(charlie).buy([id+(2n)], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price})).to.be.revertedWithCustomError(nft, 'SeriesTokenLimitExceeded');
  
    })

    it("shouldnt call setSeriesInfo as an owner of series", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        seriesId,
        seriesParams,
        nft
      } = res;
      
      await expect(nft.connect(bob)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams)).to.be.revertedWithCustomError(nft, 'CantManageThisSeries');

    })

    it("shouldnt let buy for ETH if token currency specified", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        ZERO_ADDRESS,
        seriesId,
        id,
        price,
        commissions,
        now,
        baseURI,
        suffix,
        erc20,
        nft
      } = res;
      
      const saleParams = [
        now + 100000n, 
        erc20.target, 
        price,
        0n //autoincrement price
      ];
      const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
      await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price})).to.be.revertedWithCustomError(nft, 'CurrencyInvalid');

    })

    it("shouldn correct list all tokens of user", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        ZERO_ADDRESS,
        id,
        price,
        nft
      } = res;
      
      const limit = 0n;
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).buy([id+(1n)], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).buy([id+(2n)], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const bobTokens = await nft.connect(bob).tokensByOwner(bob.address, limit);
      expect(bobTokens[0]).to.be.equal(id);
      expect(bobTokens[1]).to.be.equal(id+(1n));
      expect(bobTokens[2]).to.be.equal(id+(2n));

    })

    it("shouldn correct list null tokens if there is (2) ", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        nft
      } = res;
      
      const limit = 0n;
      const bobTokens = await nft.connect(bob).tokensByOwner(bob.address,limit);
      expect(bobTokens.length).to.be.equal(0n);
    })

    it("should correct list tokens of user with output limit", async() => {
      const res = await loadFixture(deployNFT);
      const {
        bob,
        ZERO_ADDRESS,
        id,
        price,
        nft
      } = res;
      
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).buy([id+(1n)], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      await nft.connect(bob).buy([id+(2n)], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
      const limit = 1n;
      const bobTokens = await nft.connect(bob).tokensByOwner(bob.address,limit);
      expect(bobTokens[0]).to.be.equal(id);
      expect(bobTokens.length).to.be.equal(limit);

    })

    it("shouldnt forked Series if desired seriesID is not forkable", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        ZERO_ADDRESS,
        seriesParams,
        price,
        nft
      } = res;

      const seriesIdThatCanNotBeForked = 4102n; //  4102 & 0xff != 0
      const tokenId = 10n;
      const id = seriesIdThatCanNotBeForked * (2n ** 192n)+(tokenId);
      
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesIdThatCanNotBeForked, seriesParams);

      await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 

      const forkedSeriesId = 6000n;
      await expect(nft.connect(bob).forkSeries(id, forkedSeriesId)).to.be.revertedWithCustomError(nft, 'SeriesNotForkable');

    });
    
    describe("forked Series tests", async() => {
      async function deployForkedSeriesTests() {
        const res = await loadFixture(deployNFT);
        const {
            owner,
            alice,
            now,
            price,
            baseURI,
            seriesId,
            id,
            suffix,
            commissions,
            nft,
            erc20
        } = res;

        const saleParams = [
          now + 100000n, 
          erc20.target, 
          price,
          0n //autoincrement price
        ];
        const seriesParams = [
          alice.address,  
          10000n,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
        await erc20.connect(alice).approve(nft.target, price);
        await nft.connect(alice).buy([id], erc20.target, price, false, 0n, alice.address); 
        
        return res;
      }

      

      it("shouldnt forked Series if sender isnt token's owner", async() => {
        const res = await loadFixture(deployForkedSeriesTests);
        const {
          bob,
          id,
          nft
      } = res;

        const forkedSeriesId = BigInt(0x10A0000000);
        await expect(nft.connect(bob).forkSeries(id, forkedSeriesId)).to.be.revertedWithCustomError(nft, 'NotTokenOwner');
        
      });

      
      it("shouldnt forked Series that have forked already", async() => {
        const res = await loadFixture(deployForkedSeriesTests);
        const {
          alice,
          id,
          nft
        } = res;

        const forkedSeriesId = BigInt(0x10A0000000);
        await nft.connect(alice).forkSeries(id, forkedSeriesId);

        await expect(nft.connect(alice).forkSeries(id, forkedSeriesId)).to.be.revertedWithCustomError(nft, 'AlreadyForked');

      });

      it("shouldnt forked Series that have forked already for another token", async() => {
        const res = await loadFixture(deployForkedSeriesTests);
        const {
          alice,
          bob,
          id,
          price,
          erc20,
          nft
        } = res;

        const forkedSeriesId = BigInt(0x10A0000000);
        
        await nft.connect(alice).forkSeries(id, forkedSeriesId);
        const anotherTokenId = id+(1n);
        

        await erc20.connect(bob).approve(nft.target, price);
        await nft.connect(bob).buy([anotherTokenId], erc20.target, price, false, 0n, bob.address); 

        await expect(nft.connect(bob).forkSeries(anotherTokenId, forkedSeriesId)).to.be.revertedWithCustomError(nft, 'ForkAlreadyExists');

      });
    });

    describe("hooks tests", async() => {
      it("should correct set hook (ETH test)", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          ZERO_ADDRESS,
          id,
          seriesId,
          hook1,
          price,
          nft
        } = res;
        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 1n, bob.address, {value: price});

        const tokenInfoData = await nft.tokenInfo(id);
        expect(tokenInfoData.tokenInfo.hooksCountByToken).to.be.equal(1n);
        const hooks = await nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(hook1.target);
        expect(await hook1.numberOfCalls()).to.be.equal(1n);
      })

      it("shouldn't buy if hook number changed (ETH test)", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          ZERO_ADDRESS,
          id,
          seriesId,
          hook1,
          hook2,
          price,
          nft
        } = res;

        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await nft.pushTokenTransferHook(seriesId, hook2.target);
        await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 1n, bob.address, {value: price})).to.be.revertedWith('wrong hookCount');
      })

      it("should correct set hook (token test)", async() => {

        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          id,
          seriesId,
          hook1,
          price,
          now,
          commissions,
          baseURI,
          suffix,
          erc20,
          nft
        } = res;

        const saleParams = [
          now + 100000n, 
          erc20.target, 
          price,
          0n //autoincrement price
        ]
        const seriesParams = [
          alice.address,  
          10000n,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);  
        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await erc20.connect(bob).approve(nft.target, price);
        await nft.connect(bob).buy([id], erc20.target, price, false, 1n, bob.address);

        const tokenInfoData = await nft.tokenInfo(id);
        expect(tokenInfoData.tokenInfo.hooksCountByToken).to.be.equal(1n);
        const hooks = await nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(hook1.target);
        expect(await hook1.numberOfCalls()).to.be.equal(1n);
      })

      it("shouldn't buy if hook number changed (token test)", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          id,
          seriesId,
          hook1,
          hook2,
          price,
          nft,
          erc20
        } = res;

        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await nft.pushTokenTransferHook(seriesId, hook2.target);
        await expect(nft.connect(bob).buy([id], erc20.target, price, false, 1n, bob.address)).to.be.revertedWith('wrong hookCount');
      })

      it("shouldn't buy if hook reverts", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          ZERO_ADDRESS,
          id,
          seriesId,
          badHook,
          price,
          nft
        } = res;

        await nft.pushTokenTransferHook(seriesId, badHook.target);
        await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 1n, bob.address, {value: price})).to.be.revertedWith("oops...");
      })

      it("shouldn't buy if hook returns false", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          ZERO_ADDRESS,
          id,
          seriesId,
          falseHook,
          price,
          nft
        } = res;

        await nft.pushTokenTransferHook(seriesId, falseHook.target);
        await expect(nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 1n, bob.address, {value: price})).to.be.revertedWithCustomError(nft, 'TransferNotAuthorized');
      })

      it("shouldn't buy if hook doesn't supports interface", async() => {
        const res = await loadFixture(deployNFT);
        const {
          seriesId,
          withoutFunctionHook,
          nft
        } = res;

        await expect(nft.pushTokenTransferHook(seriesId, withoutFunctionHook.target)).to.be.revertedWithCustomError(nft, 'WrongInterface');
      })

      it("shouldn't buy if hook's supportInterface function returns false", async() => {
        const res = await loadFixture(deployNFT);
        const {
          seriesId,
          notSupportingHook,
          nft
        } = res;

        await expect(nft.pushTokenTransferHook(seriesId, notSupportingHook.target)).to.be.revertedWithCustomError(nft , 'WrongInterface');
      })

      it("should correct set several hooks", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          ZERO_ADDRESS,
          id,
          seriesId,
          hook1,
          hook2,
          price,
          nft
        } = res;
        
        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await nft.pushTokenTransferHook(seriesId, hook2.target);
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 2n, bob.address, {value: price});
        
        const tokenInfoData = await nft.tokenInfo(id);
        expect(tokenInfoData.tokenInfo.hooksCountByToken).to.be.equal(2n);
        const hooks = await nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(hook1.target);
        expect(hooks[1]).to.be.equal(hook2.target);
        expect(await hook1.numberOfCalls()).to.be.equal(1n);
        expect(await hook2.numberOfCalls()).to.be.equal(1n);
      })

      it("shouldnt aplly new hook for existing token", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          charlie,
          ZERO_ADDRESS,
          id,
          seriesId,
          hook1,
          hook2,
          hook3,
          price,
          nft
        } = res;

        await nft.pushTokenTransferHook(seriesId, hook1.target);
        await nft.pushTokenTransferHook(seriesId, hook2.target);
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 2n, bob.address, {value: price});
        await nft.pushTokenTransferHook(seriesId, hook3.target);
        await nft.connect(bob).transferFrom(bob.address, charlie.address, id);
        expect(await hook1.numberOfCalls()).to.be.equal(2n);
        expect(await hook2.numberOfCalls()).to.be.equal(2n);
        expect(await hook3.numberOfCalls()).to.be.equal(0n);

        await nft.connect(charlie).buy([id+(1n)], ZERO_ADDRESS, price, false, 3n, charlie.address, {value: price});
        expect(await hook1.numberOfCalls()).to.be.equal(3n);
        expect(await hook2.numberOfCalls()).to.be.equal(3n);
        expect(await hook3.numberOfCalls()).to.be.equal(1n);

        const tokenInfoData = await nft.tokenInfo(id);
        expect(tokenInfoData.tokenInfo.hooksCountByToken).to.be.equal(2n);

        const tokenInfoDataPlusOne = await nft.tokenInfo(id+(1n));
        expect(tokenInfoDataPlusOne.tokenInfo.hooksCountByToken).to.be.equal(3n);

        const hooks = await nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(hook1.target);
        expect(hooks[1]).to.be.equal(hook2.target);
        expect(hooks[2]).to.be.equal(hook3.target);

      })

    });

    describe("safe buy tests with contract ", async() => {
      it("should correct safe buy for contract", async() => {
        const res = await loadFixture(deployNFT);
        const {
          buyerContract,
          id,
          price,
          nft
        } = res;

        await buyerContract.buyV2(nft.target, id, true, 0n, {value: price});
        expect(await nft.balanceOf(buyerContract.target)).to.be.equal(1n);
        expect(await nft.ownerOf(id)).to.be.equal(buyerContract.target);
      })

      it("should correct safe transfer to contract", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          buyerContract,
          ZERO_ADDRESS,
          id,
          price,
          nft
        } = res;

        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
        await nft.connect(bob).listForSale(id, price, ZERO_ADDRESS, 10000n);
        await buyerContract.buyV2(nft.target, id, true, 0n, {value: price});
        expect(await nft.balanceOf(buyerContract.target)).to.be.equal(1n);
        expect(await nft.ownerOf(id)).to.be.equal(buyerContract.target);
      })

      // it("shouldnt safe buy for bad contract", async() => {
      //   await expect(this.badBuyer.buyV2(nft.target, id, true, 0n, {value: price})).to.be.revertedWith("ERC721: transfer to non ERC721Receiver implementer");
      // })

    })

    describe("tests with commission", async() => {
  
      it("should correct set default commission", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          commissionReceiver,
          defaultCommissionInfo,
          maxValue,
          minValue,
          FIVE_PERCENTS,
          nft
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        const commissionInfo = await nft.commissionInfo();
        expect(commissionInfo.maxValue).to.be.equal(maxValue);
        expect(commissionInfo.minValue).to.be.equal(minValue);
        expect(commissionInfo.ownerCommission.value).to.be.equal(FIVE_PERCENTS);
        expect(commissionInfo.ownerCommission.recipient).to.be.equal(commissionReceiver.address);
      });

      it("shouldnt set default commission if not owner", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          defaultCommissionInfo,
          nft
        } = res;
        await expect(nft.connect(bob).setOwnerCommission(defaultCommissionInfo)).to.be.revertedWith("Ownable: caller is not the owner");
      });

      it("should correct set series commission", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          seriesId,
          defaultCommissionInfo,
          seriesCommissions,
          TEN_PERCENTS,
          nft
        } = res;
        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        await nft.connect(owner).setCommission(seriesId, seriesCommissions);
        const seriesInfo = await nft.seriesInfo(seriesId);
        expect(seriesInfo.commission.value).to.be.equal(TEN_PERCENTS);
        expect(seriesInfo.commission.recipient).to.be.equal(alice.address);
      });

      it("shouldnt set series commission if not owner or author", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          seriesId,
          seriesCommissions,
          nft
        } = res;
        await expect(nft.connect(bob).setCommission(seriesId, seriesCommissions)).to.be.revertedWithCustomError(nft, 'CantManageThisSeries');
      });

      it("shouldnt set series commission if it is not in the allowed range", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          seriesId,
          defaultCommissionInfo,
          maxValue,
          minValue,
          nft
        } = res;
        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        let wrongCommission = [
          minValue-(1n),
          alice.address
        ]
        await expect(nft.connect(owner).setCommission(seriesId, wrongCommission)).to.be.revertedWithCustomError(nft, 'CommissionInvalid');
        wrongCommission = [
          maxValue+(1n),
          alice.address
        ]
        await expect(nft.connect(owner).setCommission(seriesId, wrongCommission)).to.be.revertedWithCustomError(nft, 'CommissionInvalid');

      });

      it("shouldnt set series commission if receipient is invalid", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          seriesId,
          ZERO_ADDRESS,
          defaultCommissionInfo,
          TEN_PERCENTS,
          nft
        } = res;
        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        let wrongCommission = [
          TEN_PERCENTS,
          ZERO_ADDRESS
        ]
        await expect(nft.connect(owner).setCommission(seriesId, wrongCommission)).to.be.revertedWithCustomError(nft, 'RecipientInvalid');

      });

      it("should correct override cost manager", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          charlie,
          nftFactory,
          nft
        } = res;

        // here should be an factory's owner
        await nftFactory.connect(owner).renounceOverrideCostManager(nft.target);

        await nft.connect(owner).setCostManager(charlie.address);
        expect(await nft.getCostManager()).to.be.equal(charlie.address);
      });

      it("shouldnt pay commissions for primary sale with ETH (mint)", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          commissionReceiver,
          id,
          seriesId,
          defaultCommissionInfo,
          seriesCommissions,
          ZERO_ADDRESS,
          FRACTION,
          price,
          nft
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        await nft.connect(owner).setCommission(seriesId, seriesCommissions);
        const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
        const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
        const balanceBeforeReceiver = await ethers.provider.getBalance(commissionReceiver.address);
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price * 2n}); // accidentially send more than needed
        const balanceAfterBob = await ethers.provider.getBalance(bob.address);
        const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
        const balanceAfterReceiver = await ethers.provider.getBalance(commissionReceiver.address);
        
        expect(balanceBeforeBob-(balanceAfterBob)).to.be.gt(price);

        // only ownerCommission
        let feeCommission = price * (defaultCommissionInfo[2][0]) / FRACTION;

        expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(price-(feeCommission));
        expect(balanceAfterReceiver-(balanceBeforeReceiver)).to.be.equal(feeCommission);
        const newOwner = await nft.ownerOf(id);
        expect(newOwner).to.be.equal(bob.address);
  
        expect(await nft.mintedCountBySeries(seriesId)).to.be.equal(1n);

      });

      it("should pay commissions for primary sale with token (mint)", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          id,
          seriesId,
          commissionReceiver,
          defaultCommissionInfo,
          commissions,
          now,
          price, 
          baseURI,
          suffix,
          FRACTION,
          nft,
          erc20
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        //await nft.connect(owner).setCommission(seriesId, seriesCommissions);
        const saleParams = [
          now + 100000n, 
          erc20.target, 
          price,
          0n //autoincrement price
        ];
        const seriesParams = [
          alice.address, 
          10000n,
          saleParams,
          commissions, 
          baseURI,
          suffix
        ];
        await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
        await erc20.connect(bob).approve(nft.target, price);
        const balanceBeforeBob = await erc20.balanceOf(bob.address);
        const balanceBeforeAlice = await erc20.balanceOf(alice.address);
        const balanceBeforeReceiver = await erc20.balanceOf(commissionReceiver.address);
        await nft.connect(bob).buy([id], erc20.target, price * 2n, false, 0n, bob.address); // accidentially send more than needed
        const balanceAfterBob = await erc20.balanceOf(bob.address);
        const balanceAfterAlice = await erc20.balanceOf(alice.address);
        const balanceAfterReceiver = await erc20.balanceOf(commissionReceiver.address);
        
        // only ownerCommission
        let feeCommission = price * (defaultCommissionInfo[2][0]) / FRACTION;

        expect(balanceBeforeBob-(balanceAfterBob)).to.be.equal(price);
        expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(price-(feeCommission));
        expect(balanceAfterReceiver-(balanceBeforeReceiver)).to.be.equal(feeCommission);
        const newOwner = await nft.ownerOf(id);
        expect(newOwner).to.be.equal(bob.address);
          
        expect(await nft.mintedCountBySeries(seriesId)).to.be.equal(1n);
      });

      it("should correct buy minted NFT for ETH with commission", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          charlie,
          id,
          seriesId,
          price,
          ZERO_ADDRESS,
          commissionReceiver,
          defaultCommissionInfo,
          seriesCommissions,
          now,
          FRACTION,
          FIVE_PERCENTS,
          TEN_PERCENTS,
          nft
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        await nft.connect(owner).setCommission(seriesId, seriesCommissions);

        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
        const saleParams = [
          now + 100000n,
          ZERO_ADDRESS, 
          price * 2n,
          0n //autoincrement price
        ];      
  
        await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
  
        const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
        const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
        const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);
        const balanceBeforeReceiver = await ethers.provider.getBalance(commissionReceiver.address);
        await nft.connect(charlie).buy([id], ZERO_ADDRESS, price * 2n, false, 0n, charlie.address, {value: price * 3n}); // accidentially send more than needed
        const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
        const balanceAfterBob = await ethers.provider.getBalance(bob.address);
        const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
        const balanceAfterReceiver = await ethers.provider.getBalance(commissionReceiver.address);
        const defaultCommission = FIVE_PERCENTS * (price * 2n) / FRACTION; 
        const authorCommission = TEN_PERCENTS * (price * 2n) / FRACTION; 
        expect(balanceAfterBob-(balanceBeforeBob)).to.be.equal(price * 2n-(defaultCommission)-(authorCommission));
        expect(balanceBeforeCharlie-(balanceAfterCharlie)).to.be.gt(price * 2n);
        expect(balanceAfterReceiver-(balanceBeforeReceiver)).to.be.equal(defaultCommission);
        expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(authorCommission);
  
        const newOwner = await nft.ownerOf(id);
        expect(newOwner).to.be.equal(charlie.address);
  
      });

      it("should correct buy minted NFT for ETH with commission", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          charlie,
          id,
          seriesId,
          commissionReceiver,
          ZERO_ADDRESS,
          price,
          defaultCommissionInfo,
          seriesCommissions,
          now,
          FRACTION,
          FIVE_PERCENTS,
          TEN_PERCENTS,
          nft,
          erc20
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        await nft.connect(owner).setCommission(seriesId, seriesCommissions);

        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});
        const saleParams = [
          now + 100000n,
          erc20.target, 
          price * 2n,
          0n //autoincrement price
        ];      
  
        //await nft.connect(bob).setSaleInfo(id, saleParams);
        await nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
  
        const balanceBeforeAlice = await erc20.balanceOf(alice.address);
        const balanceBeforeBob = await erc20.balanceOf(bob.address);
        const balanceBeforeCharlie = await erc20.balanceOf(charlie.address);
        const balanceBeforeReceiver = await erc20.balanceOf(commissionReceiver.address);
        await erc20.connect(charlie).approve(nft.target, price * 3n);
        await nft.connect(charlie).buy([id], erc20.target, price * 3n, false, 0n, charlie.address); // accidentially send more than needed
        const balanceAfterAlice = await erc20.balanceOf(alice.address);
        const balanceAfterBob = await erc20.balanceOf(bob.address);
        const balanceAfterCharlie = await erc20.balanceOf(charlie.address);
        const balanceAfterReceiver = await erc20.balanceOf(commissionReceiver.address);
        const defaultCommission = FIVE_PERCENTS * (price * 2n) / FRACTION; 
        const authorCommission = TEN_PERCENTS * (price * 2n) / FRACTION; 
        expect(balanceAfterBob-(balanceBeforeBob)).to.be.equal(price * 2n-(defaultCommission)-(authorCommission));
        expect(balanceBeforeCharlie-(balanceAfterCharlie)).to.be.equal(price * 2n);
        expect(balanceAfterReceiver-(balanceBeforeReceiver)).to.be.equal(defaultCommission);
        expect(balanceAfterAlice-(balanceBeforeAlice)).to.be.equal(authorCommission);
  
        const newOwner = await nft.ownerOf(id);
        expect(newOwner).to.be.equal(charlie.address);
  
      });

      it("should correct consume commission when user buy nft of forked chains", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          alice,
          bob,
          charlie,
          frank,
          buyer,
          id,
          tokenId,
          ZERO_ADDRESS,
          defaultCommissionInfo,
          FRACTION,
          now,
          price,
          baseURI,
          suffix,
          FIVE_PERCENTS,
          nft,
          erc20
        } = res;

        
        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        
        
        const authors = [alice,bob,charlie,frank];
        
        const forkedSeriesIds = [
          // series id = 0x1000000000
          BigInt(0x100A000000), //alice,
          BigInt(0x100A0B0000), //bob,
          BigInt(0x100A0B0C00), //charlies,
          BigInt(0x100A0B0C0D), //frank
        ];

        const initialAuthorTokenBalances=[];
        for (let j = 0; j < authors.length; j++) {
          initialAuthorTokenBalances[j] = await erc20.balanceOf(authors[j].address);
        }

        // plan is simple.
        // buyer buy tokenId#1 for alice.
        //    alice: 
        //      -- fork series from own token. 
        //      -- setSeriesInfo with own Alice' commission
        // buyer buy the tokenId#2 in forked series for bob
        //    bob: 
        //      -- fork series from own token. 
        //      -- setSeriesInfo with own Bob' commission
        // buyer buy the tokenId#3 in forked series for charlie
        //    charlie: 
        //      -- fork series from own token. 
        //      -- setSeriesInfo with own Charlie' commission
        // buyer buy the same tokenId#4 but in forked series for frank
        // and now we will check the following:
        // while token#4 was buyed we will check user's balance
        // Alice balance is   price - ownercommission - feeWhenSellToken#1 + feeWhenSellToken#2 + feeWhenSellToken#3 + feeWhenSellToken#4
        // Bob balance is     price - ownercommission - feeWhenSellToken#1 - feeWhenSellToken#2 + feeWhenSellToken#3 + feeWhenSellToken#4
        // Charlie balance is price - ownercommission - feeWhenSellToken#1 - feeWhenSellToken#2 - feeWhenSellToken#3 + feeWhenSellToken#4
        // Frank balance is   0 (didnt changed) he is owner of tokenId#4
        // buyer lost price*4 and sould be owner of tokens: tokenId#1, tokenId#2, tokenId#3 


        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);

        await nft.connect(buyer).buy([id], ZERO_ADDRESS, price, false, 0n, authors[0].address, {value: price});

        let iTokenId = id;
        let idFromForkedSeries;

        const saleParamsForked = [
          now + 100000n, 
          erc20.target, 
          price,
          0n //autoincrement price
        ];


        // loop over authors and every person(except last one) will buy token and fork series from that token.
        // we will expect that buyer from last stage will pay commission to (0,n-1) people in array
        for (let i = 0; i < authors.length; i++) {

          await nft.connect(authors[i]).forkSeries(iTokenId, forkedSeriesIds[i]);

          await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](
            forkedSeriesIds[i], 
            [
              authors[i].address,  
              10000n,
              saleParamsForked,
              //commissions,
              [
                FIVE_PERCENTS, //fraction
                authors[i].address
              ],
              //--
              baseURI,
              suffix
            ]
          );

          idFromForkedSeries = forkedSeriesIds[i] * (2n ** 192n)+(tokenId);
          iTokenId = idFromForkedSeries;
          // 3 

          if (i+2 == authors.length) {
            // last buy we will do outside loop
            break;
          }
          let t = await erc20.balanceOf(authors[i].address);
          // "buy from forked series"
          await erc20.connect(buyer).approve(nft.target, price * 3n);
          await nft.connect(buyer).buy([idFromForkedSeries], erc20.target, price * 3n, false, 0n, authors[i+1].address); // accidentially send more than needed
          
          
        }

        
        let authorsBalancesBefore = [];
        let authorsBalancesAfter = [];
        const buyerBalanceBefore = await erc20.balanceOf(buyer.address);
        for (let i = 0; i < authors.length; i++) {
          authorsBalancesBefore[i] = await erc20.balanceOf(authors[i].address);
        }

        await erc20.connect(buyer).approve(nft.target, price * 3n);
        await nft.connect(buyer).buy([idFromForkedSeries], erc20.target, price * 3n, false, 0n, authors[authors.length-1].address); // accidentially send more than needed

        const buyerBalanceAfter = await erc20.balanceOf(buyer.address);
        for (let i = 0; i < authors.length; i++) {
          authorsBalancesAfter[i] = await erc20.balanceOf(authors[i].address);
        }

        // in total
        // all authors was an token's owner.
        // all authors in chain got fee - (i+1)*5%*price/fraction.
        //  except the last one. last author - just owner of token

        for (let i = 0; i < authors.length-1; i++) {          
          
          let ExpectedAuthorsBalancesAfter = initialAuthorTokenBalances[i]
            +(price)
            -(
              //owner commission
              price * (FIVE_PERCENTS) / FRACTION
            )
            -(
              price * (FIVE_PERCENTS) / FRACTION * BigInt(i+1)
            )
            +(
              price * (FIVE_PERCENTS) / FRACTION * BigInt(authors.length-i-1)
            );
          
          expect(authorsBalancesAfter[i]).to.be.eq(ExpectedAuthorsBalancesAfter);
        }

        expect(
          authorsBalancesAfter[authors.length-1]
        ).to.be.eq(
          initialAuthorTokenBalances[authors.length-1]
        );

        expect(
          await nft.ownerOf(idFromForkedSeries)
        ).to.be.eq(
          authors[authors.length-1].address
        )

      });

      it("should correct remove commission", async() => {
        const res = await loadFixture(deployNFT);
        const {
          owner,
          seriesId,
          ZERO_ADDRESS,
          defaultCommissionInfo,
          seriesCommissions,
          nft
        } = res;

        await nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
        await nft.connect(owner).setCommission(seriesId, seriesCommissions);
        await nft.connect(owner).removeCommission(seriesId);
        const seriesInfo = await nft.seriesInfo(seriesId);
        expect(seriesInfo.commission.value).to.be.equal(0n);
        expect(seriesInfo.commission.recipient).to.be.equal(ZERO_ADDRESS);

      });

    })

    describe("transfer tests", async() => {
      
      it("should correct transfer token via transfer()", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          buyerContract,
          ZERO_ADDRESS,
          id,
          price,
          nft
        } = res;
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
        await nft.connect(bob).transfer(buyerContract.target, id);
        expect(await nft.ownerOf(id)).to.be.equal(buyerContract.target);
        expect(await nft.balanceOf(buyerContract.target)).to.be.equal(1n);

      });

      it("should correct safe transfer token via safeTransfer()", async() => {
        const res = await loadFixture(deployNFT);
        const {
          bob,
          buyerContract,
          ZERO_ADDRESS,
          id,
          price,
          nft
        } = res;
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
        await nft.connect(bob).safeTransfer(buyerContract.target, id);
        expect(await nft.ownerOf(id)).to.be.equal(buyerContract.target);
        expect(await nft.balanceOf(buyerContract.target)).to.be.equal(1n);

      });

    })
  });

/*
  describe("buy tests with whitelist options", async() => {
  
    const roleForTransfer=14;
    const roleForBuy=15;

    it("shouldnt buy if buyer not in whitelist", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        bob,
        ZERO_ADDRESS,  
        id,
        price,
        seriesId, 
        seriesParams,
        mockCommunity,
        nft
      } = res;

      await mockCommunity.connect(owner).setRoles(bob.address, [10,11,13]);

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string),(address,uint8),(address,uint8))"](
        seriesId, 
        seriesParams,
        [ // disableWhitelist
          ZERO_ADDRESS,
          255
        ],
        [
          mockCommunity.target,
          roleForBuy//"roleForBuy"
        ]
      );

      await expect(
        nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price})
      ).to.be.revertedWithCustomError(nft, 'BuyerInvalid');
      

    });

    it("shouldnt transfer if recipient not in whitelist(while buying)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        bob,
        ZERO_ADDRESS,  
        id,
        price,
        seriesId, 
        seriesParams,
        mockCommunity,
        nft
      } = res;

      await mockCommunity.connect(owner).setRoles(bob.address, [roleForBuy]);

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string),(address,uint8),(address,uint8))"](
        seriesId, 
        seriesParams,
        [
          mockCommunity.target,
          roleForTransfer//"roleForTransfer"
        ],
        [
          mockCommunity.target,
          roleForBuy//"roleForBuy"
        ]
      );

      await expect(
        nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price})
      ).to.be.revertedWithCustomError(nft, 'RecipientInvalid');
      
    });

    it("shouldnt transfer if recipient not in whitelist(while simple transfer)", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        ZERO_ADDRESS,  
        id,
        price,
        seriesId, 
        seriesParams,
        mockCommunity,
        nft
      } = res;
      await mockCommunity.connect(owner).setRoles(bob.address, [roleForBuy,roleForTransfer]);

      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string),(address,uint8),(address,uint8))"](
        seriesId, 
        seriesParams,
        [
          mockCommunity.target,
          roleForTransfer//"roleForTransfer"
        ],
        [
          mockCommunity.target,
          roleForBuy//"roleForBuy"
        ]
      );
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});

      const newOwner = await nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);

      await mockCommunity.connect(owner).setRoles(bob.address, [roleForBuy]);

      await expect(
        nft.connect(bob).transfer(alice.address, id)
      ).to.be.revertedWithCustomError(nft, 'RecipientInvalid');
      
    });

    it("should buy and transfer", async() => {
      const res = await loadFixture(deployNFT);
      const {
        owner,
        alice,
        bob,
        ZERO_ADDRESS,  
        id,
        price,
        seriesId, 
        seriesParams,
        mockCommunity,
        nft
      } = res;

      await mockCommunity.connect(owner).setRoles(bob.address, [roleForBuy, roleForTransfer]);
      await mockCommunity.connect(owner).setRoles(alice.address, [roleForTransfer]);
      await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string),(address,uint8),(address,uint8))"](
        seriesId, 
        seriesParams,
        [
          mockCommunity.target,
          roleForTransfer//"roleForTransfer"
        ],
        [
          mockCommunity.target,
          roleForBuy//"roleForBuy"
        ]
      );
      await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price});

      const newOwner = await nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);

      await nft.connect(bob).transfer(alice.address, id);

      const newOwner2 = await nft.ownerOf(id);
      expect(newOwner2).to.be.equal(alice.address);

    });
  });
*/
});




