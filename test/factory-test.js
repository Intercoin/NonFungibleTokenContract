const { ethers} = require('hardhat');
const { expect } = require('chai');
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

require("@nomicfoundation/hardhat-chai-matchers");

const { 
    deployFactoryWithoutCostManager,
    deployNFT
} = require("./fixtures/deploy.js");

describe("Factory tests", async() => {

    it("should correct deploy instance and do usual buy test", async() => {
        const res = await loadFixture(deployFactoryWithoutCostManager);
        const {
            owner,
            ZERO_ADDRESS,
            nftFactory
        } = res;

        const name = "NAME 1";
        const symbol = "SMBL1";
        await nftFactory["produce(string,string,string)"](name, symbol, "");
        const hash = ethers.solidityPackedKeccak256(["string", "string"], [name, symbol]);
        const instance = await nftFactory.getInstance(hash);
        //console.log('instance = ', instance);
        expect(instance).to.not.be.equal(ZERO_ADDRESS);

        expect(await nftFactory.instancesCount()).to.be.equal(1n);

        const instanceInfo0 = await nftFactory.getInstanceInfo(0);
        expect(instanceInfo0.name).to.be.equal(name);
        expect(instanceInfo0.symbol).to.be.equal(symbol);
        expect(instanceInfo0.creator).to.be.equal(owner.address);

        const contract = await ethers.getContractAt("NFT", instance);
        expect(await contract.name()).to.be.equal(name);
        expect(await contract.symbol()).to.be.equal(symbol);
        expect(await contract.owner()).to.be.equal(owner.address);
    });
    
    it("usual buy test", async() => {
        const res = await loadFixture(deployNFT);
        const {
            alice,
            bob,
            id,
            ZERO_ADDRESS,
            price,
            baseURI,
            now,
            seriesId,
            autoincrementPrice,
            nft
        } = res;
        
        const balanceBeforeBob = await ethers.provider.getBalance(bob);
        const balanceBeforeAlice = await ethers.provider.getBalance(alice);
        await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price * 2n}); // accidentially send more than needed
        const balanceAfterBob = await ethers.provider.getBalance(bob);
        const balanceAfterAlice = await ethers.provider.getBalance(alice);
        expect(balanceBeforeBob - balanceAfterBob).to.be.gt(price);
        expect(balanceAfterAlice - balanceBeforeAlice).to.be.equal(price);
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
        expect(seriesInfo.saleInfo.autoincrement).to.be.equal(autoincrementPrice);
        expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000n);
        expect(seriesInfo.baseURI).to.be.equal(baseURI);
        expect(seriesInfo.limit).to.be.equal(10000n);            
    });

    it("should correct several deploy instances", async() => {
        const res = await loadFixture(deployFactoryWithoutCostManager);
        const {
            owner,
            ZERO_ADDRESS,
            nftFactory
        } = res;

        const names = ["NAME 1", "NAME 2", "NAME 3"];
        const symbols = ["SMBL1", "SMBL2", "SMBL3"];
        await nftFactory["produce(string,string,string)"](names[0], symbols[0], "");
        await nftFactory["produce(string,string,string)"](names[1], symbols[1], "");
        await nftFactory["produce(string,string,string)"](names[2], symbols[2], "");

        expect(await nftFactory.instancesCount()).to.be.equal(3n);

        const hash1 = ethers.solidityPackedKeccak256(["string", "string"], [names[0], symbols[0]]);
        const hash2 = ethers.solidityPackedKeccak256(["string", "string"], [names[1], symbols[1]]);
        const hash3 = ethers.solidityPackedKeccak256(["string", "string"], [names[2], symbols[2]]);
        const instance1 = await nftFactory.getInstance(hash1);
        const instance2 = await nftFactory.getInstance(hash2);
        const instance3 = await nftFactory.getInstance(hash3);
        
        expect(instance1).to.not.be.equal(ZERO_ADDRESS);
        expect(instance1).to.not.be.equal(instance2.target);
        expect(instance1).to.not.be.equal(instance3.target);

        expect(instance2).to.not.be.equal(ZERO_ADDRESS);
        expect(instance2).to.not.be.equal(instance3.target);

        expect(instance3).to.not.be.equal(ZERO_ADDRESS);

        const instanceInfo1 = await nftFactory.getInstanceInfo(0);
        expect(instanceInfo1.name).to.be.equal(names[0]);
        expect(instanceInfo1.symbol).to.be.equal(symbols[0]);
        expect(instanceInfo1.creator).to.be.equal(owner.address);

        const instanceInfo2 = await nftFactory.getInstanceInfo(1);
        expect(instanceInfo2.name).to.be.equal(names[1]);
        expect(instanceInfo2.symbol).to.be.equal(symbols[1]);
        expect(instanceInfo2.creator).to.be.equal(owner.address);

        const instanceInfo3 = await nftFactory.getInstanceInfo(2);
        expect(instanceInfo3.name).to.be.equal(names[2]);
        expect(instanceInfo3.symbol).to.be.equal(symbols[2]);
        expect(instanceInfo3.creator).to.be.equal(owner.address);
    })

    it("shouldn't deploy instance with the existing name and symbol", async() => {
        const res = await loadFixture(deployFactoryWithoutCostManager);
        const {
            nftFactory
        } = res;
        await nftFactory["produce(string,string,string)"]("NAME", "SMBL", "");
        await expect(nftFactory["produce(string,string,string)"]("NAME", "SMBL", "")).to.be.revertedWith("Factory: ALREADY_EXISTS");
    })

    it("shouldn't deploy instance with empty name or symbol", async() => {
        const res = await loadFixture(deployFactoryWithoutCostManager);
        const {
            nftFactory
        } = res;
        await expect(nftFactory["produce(string,string,string)"]("", "SMBL", "")).to.be.revertedWith("Factory: EMPTY NAME");
        await expect(nftFactory["produce(string,string,string)"]("NAME", "", "")).to.be.revertedWith("Factory: EMPTY SYMBOL");
    })
});