const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';



const ZERO = BigNumber.from('0');
const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const THREE = BigNumber.from('3');
const FOUR = BigNumber.from('4');
const FIVE = BigNumber.from('5');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const SERIES_BITS = 192;

chai.use(require('chai-bignumber')());

describe("Factory tests", async() => {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    beforeEach("deployment", async() => {
        const FactoryFactory = await ethers.getContractFactory("Factory");
        const NftFactory = await ethers.getContractFactory("NFTSafeHook");

        this.nft = await NftFactory.deploy();

        const name = "NFT Edition";
        const symbol = "NFT";
        this.factory = await FactoryFactory.deploy(this.nft.address, name, symbol);
    })

    it("should correct deploy instance and do usual buy test", async() => {
        
        const name = "NAME 1";
        const symbol = "SMBL1";
        await this.factory.produce(name, symbol);
        const hash = ethers.utils.solidityKeccak256(["string", "string"], [name, symbol]);
        const instance = await this.factory.getInstance(hash);
        console.log('instance = ', instance);
        expect(instance).to.not.be.equal(ZERO_ADDRESS);

        expect(await this.factory.instancesCount()).to.be.equal(TWO);

        const instanceInfo0 = await this.factory.getInstanceInfo(0);
        expect(instanceInfo0.name).to.be.equal("NFT Edition");
        expect(instanceInfo0.symbol).to.be.equal("NFT");
        expect(instanceInfo0.creator).to.be.equal(owner.address);

        const instanceInfo1 = await this.factory.getInstanceInfo(1);
        expect(instanceInfo1.name).to.be.equal(name);
        expect(instanceInfo1.symbol).to.be.equal(symbol);
        expect(instanceInfo1.creator).to.be.equal(owner.address);

        const contract = await ethers.getContractAt("NFTSafeHook", instance);
        expect(await contract.name()).to.be.equal(name);
        expect(await contract.symbol()).to.be.equal(symbol);
        expect(await contract.owner()).to.be.equal(owner.address);

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


        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);

        const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
        const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
        await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price.mul(TWO)}); // accidentially send more than needed
        const balanceAfterBob = await ethers.provider.getBalance(bob.address);
        const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
        expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
        expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
        const newOwner = await this.nft.ownerOf(id);
        expect(newOwner).to.be.equal(bob.address);

        const saleInfo = await this.nft.getSaleInfo(id);
        expect(saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(saleInfo.price).to.be.equal(ZERO);
        expect(saleInfo.onSaleUntil).to.be.equal(ZERO);

        const seriesInfo = await this.nft.getSeriesInfo(seriesId);
        expect(seriesInfo.author).to.be.equal(alice.address);
        expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
        expect(seriesInfo.saleInfo.price).to.be.equal(price);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000);

        
    })

    it("should correct several deploy instances", async() => {
        const names = ["NAME 1", "NAME 2", "NAME 3"];
        const symbols = ["SMBL1", "SMBL2", "SMBL3"];
        await this.factory.produce(names[0], symbols[0]);
        await this.factory.produce(names[1], symbols[1]);
        await this.factory.produce(names[2], symbols[2]);

        expect(await this.factory.instancesCount()).to.be.equal(FOUR);

        const hash1 = ethers.utils.solidityKeccak256(["string", "string"], [names[0], symbols[0]]);
        const hash2 = ethers.utils.solidityKeccak256(["string", "string"], [names[1], symbols[1]]);
        const hash3 = ethers.utils.solidityKeccak256(["string", "string"], [names[2], symbols[2]]);
        const instance1 = await this.factory.getInstance(hash1);
        const instance2 = await this.factory.getInstance(hash2);
        const instance3 = await this.factory.getInstance(hash3);
        console.log('instance1 = ', instance1);
        console.log('instance2 = ', instance2);
        console.log('instance3 = ', instance3);

        expect(instance1).to.not.be.equal(ZERO_ADDRESS);
        expect(instance1).to.not.be.equal(instance2.address);
        expect(instance1).to.not.be.equal(instance3.address);

        expect(instance2).to.not.be.equal(ZERO_ADDRESS);
        expect(instance2).to.not.be.equal(instance3.address);

        expect(instance3).to.not.be.equal(ZERO_ADDRESS);

        const instanceInfo1 = await this.factory.getInstanceInfo(1);
        expect(instanceInfo1.name).to.be.equal(names[0]);
        expect(instanceInfo1.symbol).to.be.equal(symbols[0]);
        expect(instanceInfo1.creator).to.be.equal(owner.address);

        const instanceInfo2 = await this.factory.getInstanceInfo(2);
        expect(instanceInfo2.name).to.be.equal(names[1]);
        expect(instanceInfo2.symbol).to.be.equal(symbols[1]);
        expect(instanceInfo2.creator).to.be.equal(owner.address);

        const instanceInfo3 = await this.factory.getInstanceInfo(3);
        expect(instanceInfo3.name).to.be.equal(names[2]);
        expect(instanceInfo3.symbol).to.be.equal(symbols[2]);
        expect(instanceInfo3.creator).to.be.equal(owner.address);



    })

    it("shouldn't deploy instance with the existing name and symbol", async() => {
        await this.factory.produce("NAME", "SMBL");
        await expect(this.factory.produce("NAME", "SMBL")).to.be.revertedWith("Factory: ALREADY_EXISTS");
        await expect(this.factory.produce("NFT Edition", "NFT")).to.be.revertedWith("Factory: ALREADY_EXISTS");
    })

    it("shouldn't deploy instance with empty name or symbol", async() => {
        await expect(this.factory.produce("", "SMBL")).to.be.revertedWith("Factory: EMPTY NAME");
        await expect(this.factory.produce("NAME", "")).to.be.revertedWith("Factory: EMPTY SYMBOL");
    })
})