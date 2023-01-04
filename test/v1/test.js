const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');
const { time } = require('@openzeppelin/test-helpers');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';

const contractURI = "https://contracturi";

const ZERO = BigNumber.from('0');
const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const THREE = BigNumber.from('3');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const SERIES_BITS = 192;
const FRACTION = BigNumber.from('100000');

chai.use(require('chai-bignumber')());


const OPERATION_INITIALIZE = 0;
const OPERATION_SETMETADATA = 1;
const OPERATION_SETSERIESINFO = 2;
const OPERATION_SETOWNERCOMMISSION = 3;
const OPERATION_SETCOMMISSION = 4;
const OPERATION_REMOVECOMMISSION = 5;
const OPERATION_LISTFORSALE = 6;
const OPERATION_REMOVEFROMSALE = 7;
const OPERATION_MINTANDDISTRIBUTE = 8;
const OPERATION_BURN = 9;
const OPERATION_BUY = 10;
const OPERATION_TRANSFER = 11;

describe("v1 tests", function () {
  describe("NonFungibleToken tests", function () {
      const accounts = waffle.provider.getWallets();
      const owner = accounts[0];                     
      const alice = accounts[1];
      const bob = accounts[2];
      const charlie = accounts[3];
      const commissionReceiver = accounts[4];

      beforeEach("deploying", async() => {
          const ERC20Factory = await ethers.getContractFactory("MockERC20");
          const NFTFactory = await ethers.getContractFactory("NFTV1");
          const HookFactory = await ethers.getContractFactory("MockHook");
          const BadHookFactory = await ethers.getContractFactory("MockBadHook");
          const FalseHookFactory = await ethers.getContractFactory("MockFalseHook");
          const NotSupportingHookFactory = await ethers.getContractFactory("MockNotSupportingHook");
          const WithoutFunctionHookFactory = await ethers.getContractFactory("MockWithoutFunctionHook");
          const BuyerFactory = await ethers.getContractFactory("Buyer");
          const BadBuyerFactory = await ethers.getContractFactory("BadBuyer");
          const CostManagerFactory = await ethers.getContractFactory("MockCostManager");

          this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
          this.hook1 = await HookFactory.deploy();
          this.hook2 = await HookFactory.deploy();
          this.hook3 = await HookFactory.deploy();
          this.badHook = await BadHookFactory.deploy();
          this.falseHook = await FalseHookFactory.deploy();
          this.notSupportingHook = await NotSupportingHookFactory.deploy();
          this.withoutFunctionHook = await WithoutFunctionHookFactory.deploy();

          this.costManager = await CostManagerFactory.deploy();

          const retval = '0x150b7a02';
          const error = ZERO;
          this.buyer = await BuyerFactory.deploy(retval, error);
          this.badBuyer = await BadBuyerFactory.deploy();
          this.nft = await NFTFactory.deploy();

          await this.nft.connect(owner).initialize("NFT Edition", "NFT", "", "", "", this.costManager.address, ZERO_ADDRESS);

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
      const suffix = ".json";
      const saleParams = [
        now + 100000, 
        ZERO_ADDRESS, 
        price
      ];
      const commissions = [
        ZERO,
        ZERO_ADDRESS
      ]
      const params = [
        alice.address, 
        10000,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, params);
      const seriesInfo = await this.nft.seriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);
      

    })

    // it("should correct put token on sale", async() => {
    //   const seriesId = BigNumber.from('1000');
    //   const tokenId = ONE;
    //   const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    //   const price = ethers.utils.parseEther('1');
    //   const now = Math.round(Date.now() / 1000);   
    //   const baseURI = "someURI";
      
    //   const tokenParams = [
    //     alice.address, 
    //     ZERO_ADDRESS, 
    //     price, 
    //     now + 100000,
    //   ];
    //   const seriesParams = tokenParams.concat([baseURI, 10000]);

    //   await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);

    //   await this.nft.connect(alice).listForSale(id, price, ZERO_ADDRESS, 100000);
    //   const tokenInfo = await this.nft.salesInfo(id);
    //   expect(tokenInfo.owner).to.be.equal(alice.address);
    //   expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
    //   expect(tokenInfo.amount).to.be.equal(price);
    //   expect(tokenInfo.onSaleUntil).to.be.equal(now + 100000);


    // })

    describe("buy tests", async() => {
      const seriesId = BigNumber.from('1000');
      const tokenId = ONE;
      const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
      const price = ethers.utils.parseEther('1');
      const now = Math.round(Date.now() / 1000);   
      const baseURI = "";
      const suffix = ".json";
      const saleParams = [
        now + 100000, 
        ZERO_ADDRESS, 
        price,
      ];
      const commissions = [
        ZERO,
        ZERO_ADDRESS
      ];
      const seriesParams = [
        alice.address,  
        10000,
        saleParams,
        commissions,
        baseURI,
        suffix
      ];
      beforeEach("listing series on sale", async() => {
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      })

      it("should correct mint NFT with ETH if ID doesn't exist", async() => {
        const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
        const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price.mul(TWO)}); // accidentially send more than needed
        const balanceAfterBob = await ethers.provider.getBalance(bob.address);
        const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
        expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
        expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
        const newOwner = await this.nft.ownerOf(id);
        expect(newOwner).to.be.equal(bob.address);

        const salesInfoToken = await this.nft.salesInfoToken(id);
        expect(salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(salesInfoToken.saleInfo.price).to.be.equal(ZERO);
        expect(salesInfoToken.saleInfo.onSaleUntil).to.be.equal(ZERO);
        expect(salesInfoToken.ownerCommissionValue).to.be.equal(ZERO);
        expect(salesInfoToken.authorCommissionValue).to.be.equal(ZERO);

        const seriesInfo = await this.nft.seriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000);

        expect(await this.nft.mintedCountBySeries(seriesId)).to.be.equal(ONE);
    
      });

    
      it("should correct mint NFT with token if ID doesn't exist", async() => {
        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price
        ];
        const seriesParams = [
          alice.address, 
          10000,
          saleParams,
          commissions, 
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await this.erc20.connect(bob).approve(this.nft.address, price);
        const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
        const balanceBeforeAlice = await this.erc20.balanceOf(alice.address);
        await this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(TWO), false, ZERO); // accidentially send more than needed
        const balanceAfterBob = await this.erc20.balanceOf(bob.address);
        const balanceAfterAlice = await this.erc20.balanceOf(alice.address);
        expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.equal(price);
        expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
        const newOwner = await this.nft.ownerOf(id);
        expect(newOwner).to.be.equal(bob.address);
        
        const salesInfoToken = await this.nft.salesInfoToken(id);
        expect(salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(salesInfoToken.saleInfo.price).to.be.equal(ZERO);
        expect(salesInfoToken.saleInfo.onSaleUntil).to.be.equal(ZERO);
        expect(salesInfoToken.ownerCommissionValue).to.be.equal(ZERO);
        expect(salesInfoToken.authorCommissionValue).to.be.equal(ZERO);

        const seriesInfo = await this.nft.seriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(this.erc20.address);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000);

        expect(await this.nft.mintedCountBySeries(seriesId)).to.be.equal(ONE);

      });

      it("should correct buy minted NFT for ETH", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const saleParams = [
          now + 100000,
          ZERO_ADDRESS, 
          price.mul(TWO)
        ];      

        //await this.nft.connect(bob).setSaleInfo(id, saleParams);
        await this.nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);

        const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
        const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);
        await this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price.mul(TWO), false, ZERO, {value: price.mul(THREE)}); // accidentially send more than needed
        const balanceAfterBob = await ethers.provider.getBalance(bob.address);
        const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
        expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
        expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.gt(price.mul(TWO));

        const newOwner = await this.nft.ownerOf(id);
        expect(newOwner).to.be.equal(charlie.address);

        const salesInfoToken = await this.nft.salesInfoToken(id);
        expect(salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(salesInfoToken.saleInfo.price).to.be.equal(price.mul(TWO));
        expect(salesInfoToken.saleInfo.onSaleUntil).to.be.equal(ZERO);
        expect(salesInfoToken.ownerCommissionValue).to.be.equal(ZERO);
        expect(salesInfoToken.authorCommissionValue).to.be.equal(ZERO);

        const seriesInfo = await this.nft.seriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000);

      });

      it("should correct buy minted NFT for token", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const saleParams = [
          now + 100000,
          this.erc20.address, 
          price.mul(TWO),
        ];      

        //await this.nft.connect(bob).setSaleInfo(id, saleParams);
        await this.nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);

        const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
        const balanceBeforeCharlie = await this.erc20.balanceOf(charlie.address);
        await this.erc20.connect(charlie).approve(this.nft.address, price.mul(THREE));
        await this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(THREE), false, ZERO); // accidentially send more than needed
        const balanceAfterBob = await this.erc20.balanceOf(bob.address);
        const balanceAfterCharlie = await this.erc20.balanceOf(charlie.address);
        expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
        expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.equal(price.mul(TWO));

        const newOwner = await this.nft.ownerOf(id);
        expect(newOwner).to.be.equal(charlie.address);

        const salesInfoToken = await this.nft.salesInfoToken(id);
        expect(salesInfoToken.saleInfo.currency).to.be.equal(this.erc20.address);
        expect(salesInfoToken.saleInfo.price).to.be.equal(price.mul(TWO));
        expect(salesInfoToken.saleInfo.onSaleUntil).to.be.equal(ZERO);
        expect(salesInfoToken.ownerCommissionValue).to.be.equal(ZERO);
        expect(salesInfoToken.authorCommissionValue).to.be.equal(ZERO);

        const seriesInfo = await this.nft.seriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000);

      });

      it("should correct mint NFT from own series", async() => {
        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price, 
        ];
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await this.erc20.connect(alice).approve(this.nft.address, price);
        await this.nft.connect(alice)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO); 
      })

      it("shouldnt buy if token was burned (ETH)", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id,  price, false, ZERO, {value: price});
        await this.nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
        await expect(this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith("token is not on sale");
      })

      it("should correct set metadata", async() => {
        const newBaseURI = "https://newBaseURI/";
        const newSuffix = "newSuffix";
        const newContractURI = "newContractURI";
        await this.nft.setBaseURI(newBaseURI);
        expect(await this.nft.baseURI()).to.be.equal(newBaseURI);
        await this.nft.setSuffix(newSuffix);
        expect(await this.nft.suffix()).to.be.equal(newSuffix);
        await this.nft.setContractURI(newContractURI);
        expect(await this.nft.contractURI()).to.be.equal(newContractURI);

      });

      it("shouldnt buy if token was burned (token)", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
        await this.erc20.connect(charlie).approve(this.nft.address, price);
        await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO)).to.be.revertedWith("token is not on sale");
      })

      it("shouldnt buy if token wasnt listed on sale", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await expect(this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith('token is not on sale');
      })

      it("shouldnt buy if token was removed from sale", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const saleParams = [
          now + 100000,
          ZERO_ADDRESS, 
          price.mul(TWO),
        ];      

        await this.nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
        await this.nft.connect(bob).removeFromSale(id);
        await expect(this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith('token is not on sale');
      })

      it("shouldnt mint if series was unlisted from sale", async() => {
        const saleParams = [
          ZERO, 
          this.erc20.address, 
          price, 
        ];
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith("token is not on sale");
      })
      
      it("shouldnt buy if user passed unsufficient ETH", async() => {
        await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price.sub(ONE)})).to.be.revertedWith("insufficient amount sent");
      })
      // deprecated 
      // it("shouldnt set token info if not owner", async() => {   
      //   const saleParams = [
      //     now + 100000,
      //     ZERO_ADDRESS, 
      //     price.mul(TWO),
      //     ZERO, //ownerCommissionValue;
      //     ZERO  //authorCommissionValue;
      //   ];   
      //   await expect(this.nft.connect(charlie).listForSale(id, saleParams[2], saleParams[1], saleParams[0])).to.be.revertedWith("!onlyTokenOwnerAuthorOrOperator");
      // })

      it("shouldnt buy if user approved unsufficient token amount", async() => {
        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price
        ];       
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];

        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await this.erc20.connect(charlie).approve(this.nft.address, price.sub(ONE));
        await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO)).to.be.revertedWith("insufficient amount");
      })

      it("shouldnt buy if user passed unsufficient token amount", async() => {

        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price, 
        ];
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await this.erc20.connect(charlie).approve(this.nft.address, price);
        await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.sub(ONE), false, ZERO)).to.be.revertedWith("insufficient amount");
      })

      it("shouldnt buy if token is invalid", async() => {
        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price, 
        ];
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await this.erc20.connect(charlie).approve(this.nft.address, price);
        const wrongAddress = bob.address;
        await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, wrongAddress, price, false, ZERO)).to.be.revertedWith("wrong currency for sale");
      })

      it("should correct list on sale via listForSale", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const duration = 1000;
        const newPrice = price.mul(TWO);
        const newCurrency = this.erc20.address;
        await this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);
        const salesInfoToken = await this.nft.salesInfoToken(id);
        expect(salesInfoToken.saleInfo.currency).to.be.equal(newCurrency);
        expect(salesInfoToken.saleInfo.price).to.be.equal(newPrice);
        const lastTs = await time.latest();
        expect(salesInfoToken.saleInfo.onSaleUntil).to.be.equal(+lastTs.toString() + duration);

      })

      it("shouldnt list on sale via listForSale if already listed", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const duration = 1000;
        const newPrice = price.mul(TWO);
        const newCurrency = this.erc20.address;
        
        await this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);
        
        await expect(this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith("already on sale");
        

      })

      it("shouldnt list on sale via listForSale if not owner", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const duration = 1000;
        const newPrice = price.mul(TWO);
        const newCurrency = this.erc20.address;
        await expect(this.nft.connect(alice).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith('you can\'t manage this token');

      })

      it("shouldnt list on sale via listForSale if duration is invalid", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        const duration = 0;
        const newPrice = price.mul(TWO);
        const newCurrency = this.erc20.address;
        await expect(this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith('invalid duration');

      })

      it("shouldnt buy burnt token", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(bob).burn(id);
        await expect(this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith('token is not on sale');
      })

      it("should mint tokens for several users via mintAndDistribute", async() => {
        const series1Id = BigNumber.from('1000');
        const series2Id = BigNumber.from('1005');
        const tokenId1 = ONE;
        const tokenId2 = TEN;
        const tokenId3 = HUN;
        const id1 = series1Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId1);
        const id2 = series2Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId2);
        const id3 = series2Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId3);
    
        const ids = [id1, id2, id3];
        const users = [
          alice.address,
          bob.address,
          charlie.address
        ]
        await this.nft.connect(owner).mintAndDistribute(ids, users);
        expect(await this.nft.balanceOf(alice.address)).to.be.equal(ONE);
        expect(await this.nft.balanceOf(bob.address)).to.be.equal(ONE);
        expect(await this.nft.balanceOf(charlie.address)).to.be.equal(ONE);

        expect(await this.nft.ownerOf(id1)).to.be.equal(alice.address);
        expect(await this.nft.ownerOf(id2)).to.be.equal(bob.address);
        expect(await this.nft.ownerOf(id3)).to.be.equal(charlie.address);
              
      })

      it("shouldnt mint tokens via mintAndDistribute if lengths are not the same ", async() => {
        const ids = [1, 2, 3];
        const wrongLengthAddresses = [
          alice.address,
          bob.address
        ]

        await expect(this.nft.connect(owner).mintAndDistribute(ids, wrongLengthAddresses)).to.be.revertedWith('lengths should be the same');

      })

      it("should correct call setSeriesInfo as an owner of series", async() => {
        const newLimit = 11000;
        const saleParams = [
          now + 100000, 
          ZERO_ADDRESS, 
          price, 
        ]
        const newParams = [
          alice.address,  
          newLimit,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(alice).setSeriesInfo(seriesId, newParams);
        const seriesInfo = await this.nft.seriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(newLimit);
    
      })

      it("shouldnt buy if limit exceeded", async() => {
        const newLimit = TWO;
        const saleParams = [
          now + 100000, 
          ZERO_ADDRESS, 
          price, 
        ]
        const newParams = [
          alice.address,  
          newLimit,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(alice).setSeriesInfo(seriesId, newParams);
        await this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id.add(ONE), price, false, ZERO, {value: price});
        await expect(this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id.add(TWO), price, false, ZERO, {value: price})).to.be.revertedWith("series token limit exceeded");
    
      })

      it("shouldnt call setSeriesInfo as an owner of series", async() => {
        await expect(this.nft.connect(bob).setSeriesInfo(seriesId, seriesParams)).to.be.revertedWith('you can\'t manage this series');

      })

      it("shouldnt let buy for ETH if token currency specified", async() => {
        const saleParams = [
          now + 100000, 
          this.erc20.address, 
          price, 
        ];
        const seriesParams = [
          alice.address,  
          10000,
          saleParams,
          commissions,
          baseURI,
          suffix
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
        await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price})).to.be.revertedWith('wrong currency for sale');

      })

      it("shouldn correct list all tokens of user", async() => {
        const limit = ZERO;
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(ONE), price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(TWO), price, false, ZERO, {value: price});
        const bobTokens = await this.nft.connect(bob).tokensByOwner(bob.address, limit);
        expect(bobTokens[0]).to.be.equal(id);
        expect(bobTokens[1]).to.be.equal(id.add(ONE));
        expect(bobTokens[2]).to.be.equal(id.add(TWO));

      })

      it("shouldn correct list null tokens if there is ", async() => {
        const limit = ZERO;
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(ONE), price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(TWO), price, false, ZERO, {value: price});
        const bobTokens = await this.nft.connect(bob).tokensByOwner(bob.address,limit);
        expect(bobTokens[0]).to.be.equal(id);
        expect(bobTokens[1]).to.be.equal(id.add(ONE));
        expect(bobTokens[2]).to.be.equal(id.add(TWO));
      })

      it("shouldn correct list null tokens if there is ", async() => {
        const limit = ZERO;
        const bobTokens = await this.nft.connect(bob).tokensByOwner(bob.address,limit);
        expect(bobTokens.length).to.be.equal(0);
      })

      it("should correct list tokens of user with output limit", async() => {
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(ONE), price, false, ZERO, {value: price});
        await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id.add(TWO), price, false, ZERO, {value: price});
        const limit = ONE;
        const bobTokens = await this.nft.connect(bob).tokensByOwner(bob.address,limit);
        expect(bobTokens[0]).to.be.equal(id);
        expect(bobTokens.length).to.be.equal(limit);

      })
  
      describe("hooks tests", async() => {
        it("should correct set hook (ETH test)", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ONE, {value: price});
          expect(await this.nft.hooksCountByToken(id)).to.be.equal(ONE);
          const hooks = await this.nft.getHookList(seriesId);
          expect(hooks[0]).to.be.equal(this.hook1.address);
          expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
        })

        it("shouldn't buy if hook number changed (ETH test)", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
          await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ONE, {value: price})).to.be.revertedWith("wrong hookCount");
        })

        it("should correct set hook (token test)", async() => {
          const saleParams = [
            now + 100000, 
            this.erc20.address, 
            price, 
          ]
          const seriesParams = [
            alice.address,  
            10000,
            saleParams,
            commissions,
            baseURI,
            suffix
          ];
          await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);  
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.erc20.connect(bob).approve(this.nft.address, price);
          await this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ONE);
          expect(await this.nft.hooksCountByToken(id)).to.be.equal(ONE);
          const hooks = await this.nft.getHookList(seriesId);
          expect(hooks[0]).to.be.equal(this.hook1.address);
          expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
        })

        it("shouldn't buy if hook number changed (token test)", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
          await expect(this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ONE)).to.be.revertedWith("wrong hookCount");
        })

        it("shouldn't buy if hook reverts", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.badHook.address);
          await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ONE, {value: price})).to.be.revertedWith("oops...");
        })

        it("shouldn't buy if hook returns false", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.falseHook.address);
          await expect(this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ONE, {value: price})).to.be.revertedWith("Transfer Not Authorized");
        })

        it("shouldn't buy if hook doesn't supports interface", async() => {
          await expect(this.nft.pushTokenTransferHook(seriesId, this.withoutFunctionHook.address)).to.be.revertedWith("wrong interface");
        })

        it("shouldn't buy if hook's supportInterface function returns false", async() => {
          await expect(this.nft.pushTokenTransferHook(seriesId, this.notSupportingHook.address)).to.be.revertedWith("wrong interface");
        })

        it("should correct set several hooks", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, TWO, {value: price});
          expect(await this.nft.hooksCountByToken(id)).to.be.equal(TWO);
          const hooks = await this.nft.getHookList(seriesId);
          expect(hooks[0]).to.be.equal(this.hook1.address);
          expect(hooks[1]).to.be.equal(this.hook2.address);
          expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
          expect(await this.hook2.numberOfCalls()).to.be.equal(ONE);
        })

        it("shouldnt aplly new hook for existing token", async() => {
          await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
          await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, TWO, {value: price});
          await this.nft.pushTokenTransferHook(seriesId, this.hook3.address);
          await this.nft.connect(bob).transferFrom(bob.address, charlie.address, id);
          expect(await this.hook1.numberOfCalls()).to.be.equal(TWO);
          expect(await this.hook2.numberOfCalls()).to.be.equal(TWO);
          expect(await this.hook3.numberOfCalls()).to.be.equal(ZERO);

          await this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id.add(ONE), price, false, THREE, {value: price});
          expect(await this.hook1.numberOfCalls()).to.be.equal(THREE);
          expect(await this.hook2.numberOfCalls()).to.be.equal(THREE);
          expect(await this.hook3.numberOfCalls()).to.be.equal(ONE);

          expect(await this.nft.hooksCountByToken(id)).to.be.equal(TWO);
          expect(await this.nft.hooksCountByToken(id.add(ONE))).to.be.equal(THREE);
          const hooks = await this.nft.getHookList(seriesId);
          expect(hooks[0]).to.be.equal(this.hook1.address);
          expect(hooks[1]).to.be.equal(this.hook2.address);
          expect(hooks[2]).to.be.equal(this.hook3.address);

        })

      });


      describe("safe buy tests with contract ", async() => {
        it("should correct safe buy for contract", async() => {
          await this.buyer.buy(this.nft.address, id, true, ZERO, {value: price});
          expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
          expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
        })

        it("should correct safe transfer to contract", async() => {
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
          await this.nft.connect(bob).listForSale(id, price, ZERO_ADDRESS, 10000);
          await this.buyer.buy(this.nft.address, id, true, ZERO, {value: price});
          expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
          expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
        })

        it("shouldnt safe buy for bad contract", async() => {
          await expect(this.badBuyer.buy(this.nft.address, id, true, ZERO, {value: price})).to.be.revertedWith("ERC721: transfer to non ERC721Receiver implementer");
        })

      })

      describe("tests with commission", async() => {
        const TEN_PERCENTS = BigNumber.from('10000');
        const FIVE_PERCENTS = BigNumber.from('5000');
        const ONE_PERCENT = BigNumber.from('1000');
        const seriesCommissions = [
          TEN_PERCENTS,
          alice.address
        ];
        const maxValue = TEN_PERCENTS;
        const minValue = ONE_PERCENT;
        const defaultCommissionInfo = [
          maxValue,
          minValue,
          [
            FIVE_PERCENTS,
            commissionReceiver.address
          ]
        ];
        it("should correct set default commission", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          const commissionInfo = await this.nft.commissionInfo();
          expect(commissionInfo.maxValue).to.be.equal(maxValue);
          expect(commissionInfo.minValue).to.be.equal(minValue);
          expect(commissionInfo.ownerCommission.value).to.be.equal(FIVE_PERCENTS);
          expect(commissionInfo.ownerCommission.recipient).to.be.equal(commissionReceiver.address);
        });

        it("shouldnt set default commission if not owner", async() => {
          await expect(this.nft.connect(bob).setOwnerCommission(defaultCommissionInfo)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("should correct set series commission", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);
          const seriesInfo = await this.nft.seriesInfo(seriesId);
          expect(seriesInfo.commission.value).to.be.equal(TEN_PERCENTS);
          expect(seriesInfo.commission.recipient).to.be.equal(alice.address);
        });

        it("shouldnt set series commission if not owner or author", async() => {
          await expect(this.nft.connect(bob).setCommission(seriesId, seriesCommissions)).to.be.revertedWith('you can\'t manage this series');
        });

        it("shouldnt set series commission if it is not in the allowed range", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          let wrongCommission = [
            minValue.sub(ONE),
            alice.address
          ]
          await expect(this.nft.connect(alice).setCommission(seriesId, wrongCommission)).to.be.revertedWith("COMMISSION_INVALID");
          wrongCommission = [
            maxValue.add(ONE),
            alice.address
          ]
          await expect(this.nft.connect(alice).setCommission(seriesId, wrongCommission)).to.be.revertedWith("COMMISSION_INVALID");

        });

        it("shouldnt set series commission if receipient is invalid", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          let wrongCommission = [
            TEN_PERCENTS,
            ZERO_ADDRESS
          ]
          await expect(this.nft.connect(alice).setCommission(seriesId, wrongCommission)).to.be.revertedWith("RECIPIENT_INVALID");

        });

        it("shoud correct override cost manager", async() => {
          await this.nft.overrideCostManager(charlie.address);
          expect(await this.nft.costManager()).to.be.equal(charlie.address);
        });

        it("shouldnt pay commissions for primary sale with ETH (mint)", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);
          const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
          const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
          const balanceBeforeReceiver = await ethers.provider.getBalance(commissionReceiver.address);
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price.mul(TWO)}); // accidentially send more than needed
          const balanceAfterBob = await ethers.provider.getBalance(bob.address);
          const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
          const balanceAfterReceiver = await ethers.provider.getBalance(commissionReceiver.address);
          
          expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
          expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
          expect(balanceAfterReceiver.sub(balanceBeforeReceiver)).to.be.equal(ZERO);
          const newOwner = await this.nft.ownerOf(id);
          expect(newOwner).to.be.equal(bob.address);
    
          expect(await this.nft.mintedCountBySeries(seriesId)).to.be.equal(ONE);

        });

        it("should pay commissions for primary sale with token (mint)", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);
          const saleParams = [
            now + 100000, 
            this.erc20.address, 
            price, 
          ];
          const seriesParams = [
            alice.address, 
            10000,
            saleParams,
            commissions, 
            baseURI,
            suffix
          ];
          await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
          await this.erc20.connect(bob).approve(this.nft.address, price);
          const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
          const balanceBeforeAlice = await this.erc20.balanceOf(alice.address);
          const balanceBeforeReceiver = await this.erc20.balanceOf(commissionReceiver.address);
          await this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(TWO), false, ZERO); // accidentially send more than needed
          const balanceAfterBob = await this.erc20.balanceOf(bob.address);
          const balanceAfterAlice = await this.erc20.balanceOf(alice.address);
          const balanceAfterReceiver = await this.erc20.balanceOf(commissionReceiver.address);
          
          expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.equal(price);
          expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
          expect(balanceAfterReceiver.sub(balanceBeforeReceiver)).to.be.equal(ZERO);
          const newOwner = await this.nft.ownerOf(id);
          expect(newOwner).to.be.equal(bob.address);
            
          expect(await this.nft.mintedCountBySeries(seriesId)).to.be.equal(ONE);
        });


        it("should correct buy minted NFT for ETH with commission", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);

          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
          const saleParams = [
            now + 100000,
            ZERO_ADDRESS, 
            price.mul(TWO), 
          ];      
    
          await this.nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
    
          const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
          const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
          const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);
          const balanceBeforeReceiver = await ethers.provider.getBalance(commissionReceiver.address);
          await this.nft.connect(charlie)["buy(uint256,uint256,bool,uint256)"](id, price.mul(TWO), false, ZERO, {value: price.mul(THREE)}); // accidentially send more than needed
          const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
          const balanceAfterBob = await ethers.provider.getBalance(bob.address);
          const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
          const balanceAfterReceiver = await ethers.provider.getBalance(commissionReceiver.address);
          const defaultCommission = FIVE_PERCENTS.mul(price.mul(TWO)).div(FRACTION); 
          const authorCommission = TEN_PERCENTS.mul(price.mul(TWO)).div(FRACTION); 
          expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO).sub(defaultCommission).sub(authorCommission));
          expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.gt(price.mul(TWO));
          expect(balanceAfterReceiver.sub(balanceBeforeReceiver)).to.be.equal(defaultCommission);
          expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(authorCommission);
    
          const newOwner = await this.nft.ownerOf(id);
          expect(newOwner).to.be.equal(charlie.address);
    
        });

        

        it("should correct buy minted NFT for ETH with commission", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);

          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price});
          const saleParams = [
            now + 100000,
            this.erc20.address, 
            price.mul(TWO), 
          ];      
    
          //await this.nft.connect(bob).setSaleInfo(id, saleParams);
          await this.nft.connect(bob).listForSale(id, saleParams[2], saleParams[1], saleParams[0]);
    
          const balanceBeforeAlice = await this.erc20.balanceOf(alice.address);
          const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
          const balanceBeforeCharlie = await this.erc20.balanceOf(charlie.address);
          const balanceBeforeReceiver = await this.erc20.balanceOf(commissionReceiver.address);
          await this.erc20.connect(charlie).approve(this.nft.address, price.mul(THREE));
          await this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(THREE), false, ZERO); // accidentially send more than needed
          const balanceAfterAlice = await this.erc20.balanceOf(alice.address);
          const balanceAfterBob = await this.erc20.balanceOf(bob.address);
          const balanceAfterCharlie = await this.erc20.balanceOf(charlie.address);
          const balanceAfterReceiver = await this.erc20.balanceOf(commissionReceiver.address);
          const defaultCommission = FIVE_PERCENTS.mul(price.mul(TWO)).div(FRACTION); 
          const authorCommission = TEN_PERCENTS.mul(price.mul(TWO)).div(FRACTION); 
          expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO).sub(defaultCommission).sub(authorCommission));
          expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.equal(price.mul(TWO));
          expect(balanceAfterReceiver.sub(balanceBeforeReceiver)).to.be.equal(defaultCommission);
          expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(authorCommission);
    
          const newOwner = await this.nft.ownerOf(id);
          expect(newOwner).to.be.equal(charlie.address);
    
        });

        it("should correct remove commission", async() => {
          await this.nft.connect(owner).setOwnerCommission(defaultCommissionInfo);
          await this.nft.connect(alice).setCommission(seriesId, seriesCommissions);
          await this.nft.connect(alice).removeCommission(seriesId);
          const seriesInfo = await this.nft.seriesInfo(seriesId);
          expect(seriesInfo.commission.value).to.be.equal(ZERO);
          expect(seriesInfo.commission.recipient).to.be.equal(ZERO_ADDRESS);

        });

        


      })

      describe('transfer tests', async() => {
        // beforeEach("deploying xdescribe", async() => {
        //   console.log('deploying xdescribe');
        // });
        it('should correct transfer token via transfer()', async() => {
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price}); 
          await this.nft.connect(bob).transfer(this.buyer.address, id);
          expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
          expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);

        })
        it('should correct safe transfer token via safeTransfer()', async() => {
          await this.nft.connect(bob)["buy(uint256,uint256,bool,uint256)"](id, price, false, ZERO, {value: price}); 
          await this.nft.connect(bob).safeTransfer(this.buyer.address, id);
          expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
          expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);

        })
      })

    })
    
  });
});
    
