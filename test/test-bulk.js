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

describe("v2 tests", function () {
  describe("Bulk tests", function () {
      const accounts = waffle.provider.getWallets();
      const owner = accounts[0];                     
      const alice = accounts[1];
      const bob = accounts[2];
      const charlie = accounts[3];
      const commissionReceiver = accounts[4];

      const seriesId = BigNumber.from('1000');
      const tokenId = ONE;
      const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
      const price = ethers.utils.parseEther('1');
      const autoincrementPrice = ZERO;
      const now = Math.round(Date.now() / 1000);   
      const baseURI = "";
      const suffix = ".json";
      const saleParams = [
        now + 100000, 
        ZERO_ADDRESS, 
        price,
        autoincrementPrice
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
      

      beforeEach("deploying", async() => {
          const NFTBulkSaleFactory = await ethers.getContractFactory("NFTBulkSaleV2");

          const ERC20Factory = await ethers.getContractFactory("MockERC20");
          const NFTFactory = await ethers.getContractFactory("NFT");
          const NFTStateFactory = await ethers.getContractFactory("NFTState");
          const NFTViewFactory = await ethers.getContractFactory("NFTView");

          const HookFactory = await ethers.getContractFactory("MockHook");
          const BadHookFactory = await ethers.getContractFactory("MockBadHook");
          const FalseHookFactory = await ethers.getContractFactory("MockFalseHook");
          const NotSupportingHookFactory = await ethers.getContractFactory("MockNotSupportingHook");
          const WithoutFunctionHookFactory = await ethers.getContractFactory("MockWithoutFunctionHook");
          const BuyerFactory = await ethers.getContractFactory("Buyer");
          
          const CostManagerFactory = await ethers.getContractFactory("MockCostManager");

            this.nftBulkSale = await NFTBulkSaleFactory.deploy();
            this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
            // this.hook1 = await HookFactory.deploy();
            // this.hook2 = await HookFactory.deploy();
            // this.hook3 = await HookFactory.deploy();
            // this.badHook = await BadHookFactory.deploy();
            // this.falseHook = await FalseHookFactory.deploy();
            // this.notSupportingHook = await NotSupportingHookFactory.deploy();
            // this.withoutFunctionHook = await WithoutFunctionHookFactory.deploy();
            this.nftState = await NFTStateFactory.deploy();
            this.nftView = await NFTViewFactory.deploy();

            this.costManager = await CostManagerFactory.deploy();

          const retval = '0x150b7a02';
          const error = ZERO;
        
          this.nft = await NFTFactory.deploy();

          await this.nft.connect(owner).initialize(this.nftState.address, this.nftView.address,"NFT Edition", "NFT", "", "", "", this.costManager.address, ZERO_ADDRESS);

          await this.erc20.mint(owner.address, TOTALSUPPLY);

          await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
          await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
          await this.erc20.transfer(charlie.address, ethers.utils.parseEther('100'));

          await this.nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

          //await this.nft.connect(owner).setTrustedForwarder(this.nftBulkSale.address);
      });

      it("should correct Bulk Sale", async() => {

        const seriesId = BigNumber.from('1000');
        
        const tokenId1 = ONE;
        const tokenId2 = TEN;
        const tokenId3 = HUN;
        const id1 = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId1);
        const id2 = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId2);
        const id3 = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId3);
    
        const ids = [id1, id2, id3];
        const users = [
          alice.address,
          bob.address,
          charlie.address
        ];

        // try to distribte without setForwarder before
        await expect(
            this.nftBulkSale.connect(charlie).distribute(this.nft.address, ids, users, {value: price.mul(THREE)})
        ).to.be.revertedWith("you can't manage this series");

        expect(await this.nft.balanceOf(alice.address)).to.be.equal(ZERO);
        expect(await this.nft.balanceOf(bob.address)).to.be.equal(ZERO);
        expect(await this.nft.balanceOf(charlie.address)).to.be.equal(ZERO);


        await this.nft.connect(owner).setTrustedForwarder(this.nftBulkSale.address);
        await this.nftBulkSale.connect(charlie).distribute(this.nft.address, ids, users, {value: price.mul(THREE)});  

        //await this.nft.connect(owner).mintAndDistribute(ids, users);

        expect(await this.nft.balanceOf(alice.address)).to.be.equal(ONE);
        expect(await this.nft.balanceOf(bob.address)).to.be.equal(ONE);
        expect(await this.nft.balanceOf(charlie.address)).to.be.equal(ONE);

        expect(await this.nft.ownerOf(id1)).to.be.equal(alice.address);
        expect(await this.nft.ownerOf(id2)).to.be.equal(bob.address);
        expect(await this.nft.ownerOf(id3)).to.be.equal(charlie.address);

      });

    });
});