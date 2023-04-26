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

const accounts = waffle.provider.getWallets();
const owner = accounts[0];                     
const alice = accounts[1];
const bob = accounts[2];
const charlie = accounts[3];
const commissionReceiver = accounts[4];

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
  var nftFactory;
  beforeEach("deploying", async() => {
      const ReleaseManagerFactoryF = await ethers.getContractFactory("MockReleaseManagerFactory");
      const ReleaseManagerF = await ethers.getContractFactory("MockReleaseManager");
      const NFTFactoryF = await ethers.getContractFactory("NFTFactory");
      const NFTF = await ethers.getContractFactory("NFT");
      const NFTStateF = await ethers.getContractFactory("NFTState");
      const NFTViewF = await ethers.getContractFactory("NFTView");
      const CostManagerFactory = await ethers.getContractFactory("MockCostManager");
  
      let nftState = await NFTStateF.deploy();
      let nftView = await NFTViewF.deploy();
      let nftImpl = await NFTF.deploy();
      let implementationReleaseManager = await ReleaseManagerF.deploy();

      let releaseManagerFactory = await ReleaseManagerFactoryF.connect(owner).deploy(implementationReleaseManager.address);
      let tx,rc,event,instance,instancesCount;
      //
      tx = await releaseManagerFactory.connect(owner).produce();
      rc = await tx.wait(); // 0ms, as tx is already confirmed
      event = rc.events.find(event => event.event === 'InstanceProduced');
      [instance, instancesCount] = event.args;
      let releaseManager = await ethers.getContractAt("MockReleaseManager",instance);

      this.costManager = await CostManagerFactory.deploy();

      nftFactory = await NFTFactoryF.deploy(nftImpl.address, nftState.address, nftView.address, this.costManager.address, releaseManager.address);

      // 
      const factoriesList = [nftFactory.address];
      const factoryInfo = [
          [
              1,//uint8 factoryIndex; 
              1,//uint16 releaseTag; 
              "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
          ]
      ]
      
      await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);
  })

  describe("Bulk tests", function () {
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
          
          const HookFactory = await ethers.getContractFactory("MockHook");
          const BadHookFactory = await ethers.getContractFactory("MockBadHook");
          const FalseHookFactory = await ethers.getContractFactory("MockFalseHook");
          const NotSupportingHookFactory = await ethers.getContractFactory("MockNotSupportingHook");
          const WithoutFunctionHookFactory = await ethers.getContractFactory("MockWithoutFunctionHook");
          const BuyerFactory = await ethers.getContractFactory("Buyer");
          //const BadBuyerFactory = await ethers.getContractFactory("BadBuyer");

          this.nftBulkSale = await NFTBulkSaleFactory.deploy();
          this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
          // this.hook1 = await HookFactory.deploy();
          // this.hook2 = await HookFactory.deploy();
          // this.hook3 = await HookFactory.deploy();
          // this.badHook = await BadHookFactory.deploy();
          // this.falseHook = await FalseHookFactory.deploy();
          // this.notSupportingHook = await NotSupportingHookFactory.deploy();
          // this.withoutFunctionHook = await WithoutFunctionHookFactory.deploy();

          const retval = '0x150b7a02';
          const error = ZERO;
          //   this.buyer = await BuyerFactory.deploy(retval, error);
          //   this.badBuyer = await BadBuyerFactory.deploy();
          let tx,rc,event,instance;
          tx = await nftFactory.connect(owner)["produce(string,string,string)"]("NFT Edition", "NFT", "");
          rc = await tx.wait();
          let instanceAddr = rc['events'][0].args.instance;
          this.nft = await NFTFactory.attach(instanceAddr);

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
        ).to.be.revertedWith("CantManageThisSeries()");

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