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
const FOURTH = BigNumber.from('4');
const FIVE = BigNumber.from('5');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const ONE_ETH = BigNumber.from('1000000000000000000');

const price = ethers.utils.parseEther('1');

const SERIES_BITS = 192;
const FRACTION = BigNumber.from('100000');

chai.use(require('chai-bignumber')());

describe("tests", function () {

    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];
    const frank = accounts[4];

    const seriesId = BigNumber.from('1000');
    const autoIncrement = ONE;
    
    const rateInterval = 24*60*60;
    const rateAmount = FIVE;
    //const id1 = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId1);
    
    beforeEach("deploying", async() => {
        
        const NFTGayAliensFactory = await ethers.getContractFactory("NFTSafeHook");
        const NFTSalesFactoryFactory = await ethers.getContractFactory("NFTSalesFactory");
        const NFTSalesFactory = await ethers.getContractFactory("NFTSales");
        const LockedHookFactory = await ethers.getContractFactory("LockedHook");
    
        this.lockedHook = await LockedHookFactory.deploy();
        let nftSalesimpl = await NFTSalesFactory.deploy();
        this.nftSalesFactory = await NFTSalesFactoryFactory.deploy(nftSalesimpl.address);

        // original Gay Aliens NFT smart contract on Ethereum 0x626a67477d2dca67cac6d8133f0f9daddbfea94e
        // we here imitate the same code and create it via factory.
        this.nftGayAliens = await NFTGayAliensFactory.connect(owner).deploy();
        await this.nftGayAliens.connect(owner).initialize(
            "Gay Aliens Society (Gen 1)", 
            "GAS1", 
            "", 
            ZERO_ADDRESS,
            owner.address
        );
        //setup trusted forwarder
        await this.nftGayAliens.setTrustedForwarder(this.nftSalesFactory.address);

        let tx,rc,event,instance;
        tx = await this.nftSalesFactory.connect(owner).produce(
            this.nftGayAliens.address, //address NFTcontract,
            seriesId, // seriesId
            alice.address, //address owner, 
            ZERO_ADDRESS, //address currency, 
            ONE_ETH, //uint256 price, 
            bob.address, //address beneficiary, 
            autoIncrement, // uint192 _autoindex,
            ZERO, //uint64 duration
            rateInterval, // uint32 _rateInterval,
            rateAmount //uint16 _rateAmount
        );
        
        rc = await tx.wait(); // 0ms, as tx is already confirmed
        event = rc.events.find(event => event.event === 'InstanceCreated');
        [instance] = event.args;
        this.nftSales = await ethers.getContractAt("NFTSales",instance);
        await this.nftSales.connect(alice).setEvenIfNotOnSale(true);
    });

    it("Ability to produce smart contracts with a custom price and staking interval (if any)", async() => {
        expect(this.nftSales.address).not.to.be.eq(ZERO_ADDRESS);
    });

    it("Ability to purchase and mint multiple NFTs in the same transaction, as long as the user has enough gas.", async() => {
        
        await this.nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);
        let amount = FIVE;
        let oldOwners = [];
        let newOwners = [];
        let tokenId;
        
        
        for(let i = autoIncrement; i< autoIncrement+amount; i++) {
            oldOwners[oldOwners.length] = ZERO_ADDRESS;
            tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(i);
            await expect(this.nftGayAliens.ownerOf(tokenId)).to.be.revertedWith("ERC721: owner query for nonexistent token");

        }
        
        // gasUsed: BigNumber { value: "804639" },
        // tx was consumed around 800k. we setup manually 400k and expect that transaction will fail
        await expect(
            this.nftSales.connect(charlie).specialPurchase(charlie.address, amount, {gasLimit: 400000, value: price.mul(amount)})
        ).to.be.revertedWith("low level error");

        //try to buy 5 NFT in common case
        await this.nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price.mul(amount)})
        
        for(let i = autoIncrement; i < autoIncrement.add(amount); i++) {
            tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(i);
            newOwners[newOwners.length] = await this.nftGayAliens.ownerOf(tokenId);
        }

        for(let i = 0; i< newOwners.length; i++) {
            expect(newOwners[i]).not.to.be.eq(oldOwners[i]);
            expect(newOwners[i]).to.be.eq(charlie.address);
        }
    });

    it("Ability to transfer ownership of this smart contract", async() => {
        const ownerShouldToBe = frank.address;
        const oldOwner = await this.nftSales.owner();
        await this.nftSales.connect(alice).transferOwnership(ownerShouldToBe);
        const newOwner = await this.nftSales.owner();

        expect(oldOwner).not.to.be.eq(newOwner);
        expect(ownerShouldToBe).to.be.eq(newOwner);
    });

    it("Ability for the owner of the smart contract to manage the whitelist of who can use the Sales contract to mint NFTs from the connected NFT smart contract.", async() => {
        const isWhitelistedBefore = await this.nftSales.isWhitelisted(charlie.address);
        const amount = ONE;
        const tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(autoIncrement);
        await expect(this.nftGayAliens.ownerOf(tokenId)).to.be.revertedWith("ERC721: owner query for nonexistent token");
        await expect(
            this.nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price})
        ).to.be.revertedWith(`NotInWhiteList("${charlie.address}")`);

        await this.nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);
        const isWhitelistedAfter = await this.nftSales.isWhitelisted(charlie.address);
        await this.nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price})

        await this.nftSales.connect(alice).specialPurchasesListRemove([charlie.address]);
        const isWhitelistedAfter2 = await this.nftSales.isWhitelisted(charlie.address);

        expect(isWhitelistedBefore).to.be.false;
        expect(isWhitelistedAfter).to.be.true;
        expect(isWhitelistedAfter2).to.be.false;

    });

    it("Ability for the anyone purchases tokens but only if series `is on sale`", async() => {
        
        const tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(autoIncrement);
        const amount = 1;
        //const ownerBeforePurchase = await this.nftGayAliens.ownerOf(tokenId);
        await expect(this.nftGayAliens.ownerOf(tokenId)).to.be.revertedWith("ERC721: owner query for nonexistent token");
        await expect(
            this.nftSales.connect(charlie).purchase(charlie.address, amount, {value: price})
        ).to.be.revertedWith(`SeriesIsNotOnSale(${seriesId})`);
        
        // then put on sale
        const now = Math.round(Date.now() / 1000);   
        const baseURI = "someURI";
        const suffix = ".json";
        const saleParams = [now + 100000, ZERO_ADDRESS, price];
        const commissions = [ZERO, ZERO_ADDRESS]
        const params = [alice.address, 10000, saleParams, commissions, baseURI, suffix];
        //await this.nftGayAliens.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256),(uint64,address),string,string))"](seriesId, params);
        await this.nftGayAliens.connect(owner).setSeriesInfo(seriesId, params);

        // purchase again
        await this.nftSales.connect(charlie).purchase(charlie.address, amount, {value: price});

        const ownerAfterPurchase = await this.nftGayAliens.ownerOf(tokenId);
        await expect(ownerAfterPurchase).to.be.eq(charlie.address);

    });

    it("If there is a staking interval, this smart contract mints NFTs to itself as an owner, and allows the addresses in the whitelist to claim after the staking interval elapsed.", async() => {
        const duration = 24*60*60;

        let tx,rc,event,instance;
        tx = await this.nftSalesFactory.connect(owner).produce(
            this.nftGayAliens.address, //address NFTcontract,
            seriesId, // uint64 seriesId,
            alice.address, //address owner, 
            ZERO_ADDRESS, //address currency, 
            ONE_ETH, //uint256 price, 
            bob.address, //address beneficiary, 
            autoIncrement, // uint192 _autoindex,
            duration, //uint64 duration
            24*60*60, // uint32 _rateInterval,
            FIVE //uint16 _rateAmount
        );

        
        rc = await tx.wait(); // 0ms, as tx is already confirmed
        event = rc.events.find(event => event.event === 'InstanceCreated');
        [instance] = event.args;
        let nftSales = await ethers.getContractAt("NFTSales",instance);

        

        const tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(autoIncrement);
        const amount = 1;

        await nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);
        await expect(
            nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price})
        ).to.be.revertedWith(
            `SeriesIsNotOnSale(${seriesId})`
        );
        await nftSales.connect(alice).setEvenIfNotOnSale(true);

        await nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price});

        expect(await this.nftGayAliens.ownerOf(tokenId)).to.be.eq(nftSales.address);

        
        await expect(
            nftSales.connect(charlie).claim([tokenId])
        ).to.be.revertedWith(
            //hardcoded error params :)  remained day+1 and remained timestamp
            `StillPending(1, 86399)`
        );

        // passed time
        await ethers.provider.send('evm_increaseTime', [duration]);
        await ethers.provider.send('evm_mine');

        // still contract owner
        expect(await this.nftGayAliens.ownerOf(tokenId)).to.be.eq(nftSales.address);

        await nftSales.connect(charlie).claim([tokenId]);

        expect(await this.nftGayAliens.ownerOf(tokenId)).to.be.eq(charlie.address);

    });

    it("NFT's owner should produce NFTSale only for own NFT.", async() => {
        await expect(
            this.nftSalesFactory.connect(frank).produce(
                this.nftGayAliens.address, //address NFTcontract,
                seriesId, // uint64 seriesId,
                alice.address, //address owner, 
                ZERO_ADDRESS, //address currency, 
                ONE_ETH, //uint256 price, 
                bob.address, //address beneficiary, 
                autoIncrement, // uint192 _autoindex,
                ZERO, //uint64 duration
                24*60*60, // uint32 _rateInterval,
                FIVE //uint16 _rateAmount
            )
        ).to.be.revertedWith(`OwnerOfNFTContractOnly("${this.nftGayAliens.address}", "${owner.address}")`);


    });

    it("check rateInterval and rateAmount for special and common purchases", async() => {

        const duration = 24*60*60;
        var nftSales;

        let tx,rc,event,instance;
        tx = await this.nftSalesFactory.connect(owner).produce(
            this.nftGayAliens.address, //address NFTcontract,
            seriesId, // uint64 seriesId,
            alice.address, //address owner, 
            ZERO_ADDRESS, //address currency, 
            ONE_ETH, //uint256 price, 
            bob.address, //address beneficiary, 
            autoIncrement, // uint192 _autoindex,
            duration, //uint64 duration
            rateInterval, // uint32 _rateInterval,
            rateAmount //uint16 _rateAmount
        );

        
        rc = await tx.wait(); // 0ms, as tx is already confirmed
        event = rc.events.find(event => event.event === 'InstanceCreated');
        [instance] = event.args;
        nftSales = await ethers.getContractAt("NFTSales",instance);

        // then put on sale
        const now = Math.round(Date.now() / 1000);   
        const baseURI = "someURI";
        const suffix = ".json";
        const saleParams = [now + 100000, ZERO_ADDRESS, price];
        const commissions = [ZERO, ZERO_ADDRESS]
        const params = [alice.address, 10000, saleParams, commissions, baseURI, suffix];
        //await this.nftGayAliens.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256),(uint64,address),string,string))"](seriesId, params);
        await this.nftGayAliens.connect(owner).setSeriesInfo(seriesId, params);
    

        await nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);

        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});

        // make common purchase. it should not increase  rate variables
        await nftSales.connect(charlie).purchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).purchase(charlie.address, ONE, {value: price});
        await nftSales.connect(charlie).purchase(charlie.address, ONE, {value: price});

        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        const timestampBefore = blockBefore.timestamp;

        await expect(
            nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price})
        ).to.be.revertedWith(`TooMuchBoughtInCurrentInterval(${Math.floor(timestampBefore/rateInterval)*rateInterval}, ${rateAmount.add(1)}, ${rateAmount})`);

        // passed time
        await ethers.provider.send('evm_increaseTime', [duration]);
        await ethers.provider.send('evm_mine');

        await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});

    });

    it("try to mint if token[autoindex] has too many tokens that need to skip", async() => {

        const duration = 24*60*60;
        var nftSales;

        let tx,rc,event,instance;
        tx = await this.nftSalesFactory.connect(owner).produce(
            this.nftGayAliens.address, //address NFTcontract,
            seriesId, // uint64 seriesId,
            alice.address, //address owner, 
            ZERO_ADDRESS, //address currency, 
            ethers.utils.parseEther("0.01"), //uint256 price, 
            bob.address, //address beneficiary, 
            autoIncrement, // uint192 _autoindex,
            ZERO, //uint64 duration
            rateInterval, // uint32 _rateInterval,
            TWO.mul(HUN) //uint16 _rateAmount
        );

        
        rc = await tx.wait(); // 0ms, as tx is already confirmed
        event = rc.events.find(event => event.event === 'InstanceCreated');
        [instance] = event.args;
        nftSales = await ethers.getContractAt("NFTSales",instance);

        await nftSales.connect(alice).setEvenIfNotOnSale(true);
        await nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);
        await nftSales.connect(alice).setAutoIndex(HUN);
        
        // make common purchase. it should not increase  rate variables
        for (let i = 0; i< 100; i++) {
            await nftSales.connect(charlie).specialPurchase(charlie.address, ONE, {value: price});
        }

        await nftSales.connect(alice).specialPurchasesListAdd([frank.address]);
        await nftSales.connect(alice).setAutoIndex(HUN.sub(FIVE));
        for (let i = 0; i< 10; i++) {
            await nftSales.connect(frank).specialPurchase(frank.address, ONE, {value: price});
        }
        
        let expectedTokens = [
            HUN.sub(FIVE).add(0),
            HUN.sub(FIVE).add(1),
            HUN.sub(FIVE).add(2),
            HUN.sub(FIVE).add(3),
            HUN.sub(FIVE).add(4),

            HUN.add(HUN).add(0),
            HUN.add(HUN).add(1),
            HUN.add(HUN).add(2),
            HUN.add(HUN).add(3),
            HUN.add(HUN).add(4),
        ];

        
        for (let i = 0; i< 10; i++) {
            let tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(expectedTokens[i]);
            expect(await this.nftGayAliens.ownerOf(tokenId)).to.be.eq(frank.address);
        }
        

    });

    it("token should be locked after hook setup and locked by owner", async() => {

        await this.nftGayAliens.connect(owner).pushTokenTransferHook(seriesId, this.lockedHook.address);

        await this.nftSales.connect(alice).specialPurchasesListAdd([charlie.address]);

        const amount = ONE;
        await this.nftSales.connect(charlie).specialPurchase(charlie.address, amount, {value: price.mul(amount)})

        let tokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(autoIncrement);

        let tokenOwner = await this.nftGayAliens.ownerOf(tokenId);
    
        expect(tokenOwner).to.be.eq(charlie.address);

        //  locked token
        await this.lockedHook.connect(charlie).lock(this.nftGayAliens.address, tokenId, bob.address);


        await expect(
            this.nftGayAliens.connect(charlie).transfer(frank.address, tokenId)
        ).to.be.revertedWith(`Transfer Not Authorized`);


        // but if unlock 
        await expect(
            this.lockedHook.connect(charlie).unlock(this.nftGayAliens.address, tokenId)
        ).to.be.revertedWith(`NotACustodian("${this.nftGayAliens.address}", ${tokenId})`);

        await this.lockedHook.connect(bob).unlock(this.nftGayAliens.address, tokenId);

        // then be able to transfer
        await this.nftGayAliens.connect(charlie).transfer(frank.address, tokenId)

    });

    it("check whitelist ", async() => {
        let whitelistedBefore = await this.nftSales["whitelisted()"]();
        await this.nftSales.connect(alice).specialPurchasesListAdd([
            bob.address,
            charlie.address,
            frank.address
        ]);
        let whitelistedAfter = await this.nftSales["whitelisted()"]();

        expect(whitelistedBefore.length).to.be.eq(ZERO);

        expect(whitelistedAfter[0]).to.be.eq(bob.address);
        expect(whitelistedAfter[1]).to.be.eq(charlie.address);
        expect(whitelistedAfter[2]).to.be.eq(frank.address);
    });

    it("check whitelist with paginations ", async() => {

        await expect(this.nftSales["whitelisted(uint256,uint256)"](0,0)).to.be.revertedWith(`IncorrectInputParameters()`);
        await expect(this.nftSales["whitelisted(uint256,uint256)"](5,0)).to.be.revertedWith(`IncorrectInputParameters()`);
        await expect(this.nftSales["whitelisted(uint256,uint256)"](0,5)).to.be.revertedWith(`IncorrectInputParameters()`);

        expect((await this.nftSales["whitelisted(uint256,uint256)"](1,1)).length).to.be.eq(ZERO);
        expect((await this.nftSales["whitelisted(uint256,uint256)"](2,1)).length).to.be.eq(ZERO);
        expect((await this.nftSales["whitelisted(uint256,uint256)"](1,2)).length).to.be.eq(ZERO);
        expect((await this.nftSales["whitelisted(uint256,uint256)"](6,6)).length).to.be.eq(ZERO);

        await this.nftSales.connect(alice).specialPurchasesListAdd([
            bob.address,
            charlie.address,
            frank.address
        ]);

        let whitelistArr;
        // emulate requests with one items on pagination page 
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](1,1);
        expect(whitelistArr[0]).to.be.eq(bob.address);
        
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](2,1);
        expect(whitelistArr[0]).to.be.eq(charlie.address);
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](3,1);
        expect(whitelistArr[0]).to.be.eq(frank.address);
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](4,1);
        expect(whitelistArr.length).to.be.eq(ZERO);

        // emulate requests with two items on pagination page 
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](1,2);
        expect(whitelistArr[0]).to.be.eq(bob.address);     
        expect(whitelistArr[1]).to.be.eq(charlie.address);     
        
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](2,2);
        expect(whitelistArr[0]).to.be.eq(frank.address); 
        expect(whitelistArr.length).to.be.eq(ONE);    

        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](3,2);
        expect(whitelistArr.length).to.be.eq(ZERO);


        await this.nftSales.connect(alice).specialPurchasesListAdd([owner.address]);
        // emulate requests with three items on pagination page 
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](1,3);
        expect(whitelistArr[0]).to.be.eq(bob.address);
        expect(whitelistArr[1]).to.be.eq(charlie.address);     
        expect(whitelistArr[2]).to.be.eq(frank.address);     
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](2,3);
        expect(whitelistArr[0]).to.be.eq(owner.address); 
        expect(whitelistArr.length).to.be.eq(ONE);    
        whitelistArr = await this.nftSales["whitelisted(uint256,uint256)"](3,3);
        expect(whitelistArr.length).to.be.eq(ZERO);
    });

});