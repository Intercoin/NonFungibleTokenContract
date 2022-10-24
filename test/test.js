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

const ONE_ETH = BigNumber.from('1000000000000000000');

const SERIES_BITS = 192;
const FRACTION = BigNumber.from('100000');

chai.use(require('chai-bignumber')());

describe("tests", function () {

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
    
    beforeEach("deploying", async() => {
        //const NFTBulkSaleFactory = await ethers.getContractFactory("BulkSale");

    //   const ERC20Factory = await ethers.getContractFactory("MockERC20");
        const NFTGayAliensFactory = await ethers.getContractFactory("NFTSafeHook");
        const NFTSalesFactoryFactory = await ethers.getContractFactory("NFTSalesFactory");
        const NFTSalesFactory = await ethers.getContractFactory("NFTSales");
    
        let nftSalesimpl = await NFTSalesFactory.deploy();

        this.nftSalesFactory = await NFTSalesFactoryFactory.deploy(nftSalesimpl.address);

        //this.nftBulkSale = await NFTBulkSaleFactory.connect(owner).deploy();

        // imitate create via factory.
        this.nftGayAliens = await NFTGayAliensFactory.connect(owner).deploy();
        await this.nftGayAliens.connect(owner).initialize(
            "Gay Aliens Society (Gen 1)", 
            "GAS1", 
            "", 
            ZERO_ADDRESS,
            owner.address
        );
    });

    //
    it("Ability to produce smart contracts with a custom price and staking interval (if any)", async() => {
        let tx,rc,event,instance;
        tx = await this.nftSalesFactory.connect(owner).produce(
            this.nftGayAliens.address, //address NFTcontract,
            alice.address, //address owner, 
            ZERO_ADDRESS, //address currency, 
            ONE_ETH, //uint256 price, 
            bob.address, //address beneficiary, 
            ZERO, //uint64 duration
        );
        
        rc = await tx.wait(); // 0ms, as tx is already confirmed
        event = rc.events.find(event => event.event === 'InstanceCreated');
        [instance] = event.args;
        let nftSafeHook = await ethers.getContractAt("NFTSafeHook",instance);

        expect(nftSafeHook.address).not.to.be.eq(ZERO_ADDRESS);

    });

    // Connection with original Gay Aliens NFT smart contract on Ethereum 0x626a67477d2dca67cac6d8133f0f9daddbfea94e
    it("Ability to purchase and mint multiple NFTs in the same transaction, as long as the user has enough gas.", async() => {});
    it("Ability to transfer ownership of this smart contract", async() => {});
    it("Ability for the owner of the smart contract to manage the whitelist of who can use the Sales contract to mint NFTs from the connected NFT smart contract.", async() => {});
    it("If there is a staking interval, this smart contract mints NFTs to itself as an owner, and allows the addresses in the whitelist to claim after the staking interval elapsed.", async() => {});
    


    xit("should correct mint NFT with ETH if ID doesn't exist", async() => {

        const seriesId = BigNumber.from('1000');
        await expect(ONE).to.be.eq(ONE);
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

        // await expect(
        //     this.nftBulkSale.connect(charlie).distribute(this.nftGayAliens.address, ids, users, {value: price.mul(THREE)})
        // ).to.be.revertedWith("you can't manage this series");
    });

});