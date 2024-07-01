const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';

const contractURI = "https://contracturi";

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

describe("v2 tests", function () {
    describe("Factory tests", async() => {
        const accounts = waffle.provider.getWallets();
        const owner = accounts[0];                     
        const alice = accounts[1];
        const bob = accounts[2];
        const charlie = accounts[3];

        beforeEach("deployment", async() => {
            const ReleaseManagerFactoryF = await ethers.getContractFactory("ReleaseManagerFactory");
            const CostManagerGoodF = await ethers.getContractFactory("MockCostManagerGood");
            const CostManagerBadF = await ethers.getContractFactory("MockCostManagerBad");

            const ReleaseManagerF = await ethers.getContractFactory("ReleaseManager");

            const FactoryFactory = await ethers.getContractFactory("NFTFactory");
            const NFTFactory = await ethers.getContractFactory("NFT");
            const CostManagerFactory = await ethers.getContractFactory("MockCostManager");

            const NFTStateFactory = await ethers.getContractFactory("NFTState");
            const NFTViewFactory = await ethers.getContractFactory("NFTView");

            this.costManagerGood = await CostManagerGoodF.deploy();
            this.costManagerBad = await CostManagerBadF.deploy();

            let implementationReleaseManager    = await ReleaseManagerF.deploy();

            this.nftState = await NFTStateFactory.deploy();
            this.nftView = await NFTViewFactory.deploy();

            this.costManager = await CostManagerFactory.deploy();

            this.nft = await NFTFactory.deploy();

            const name = "NFT Edition";
            const symbol = "NFT";

            let releaseManagerFactory   = await ReleaseManagerFactoryF.connect(owner).deploy(implementationReleaseManager.address);
            let tx,rc,event,instance,instancesCount;
            //
            tx = await releaseManagerFactory.connect(owner).produce();
            rc = await tx.wait(); // 0ms, as tx is already confirmed
            event = rc.events.find(event => event.event === 'InstanceProduced');
            [instance, instancesCount] = event.args;
            let releaseManager = await ethers.getContractAt("ReleaseManager",instance);

            this.factory = await FactoryFactory.deploy(this.nft.address, this.nftState.address, this.nftView.address, ZERO_ADDRESS, releaseManager.address);
            
            // 
            const factoriesList = [this.factory.address];
            const factoryInfo = [
                [
                    1,//uint8 factoryIndex; 
                    1,//uint16 releaseTag; 
                    "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
                ]
            ]
            await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);
        })

        it("should correct deploy instance and do usual buy test", async() => {
            const name = "NAME 1";
            const symbol = "SMBL1";
            await this.factory["produce(string,string,string)"](name, symbol, "");
            const hash = ethers.utils.solidityKeccak256(["string", "string"], [name, symbol]);
            const instance = await this.factory.getInstance(hash);
            //console.log('instance = ', instance);
            expect(instance).to.not.be.equal(ZERO_ADDRESS);

            expect(await this.factory.instancesCount()).to.be.equal(ONE);

            const instanceInfo0 = await this.factory.getInstanceInfo(0);
            expect(instanceInfo0.name).to.be.equal(name);
            expect(instanceInfo0.symbol).to.be.equal(symbol);
            expect(instanceInfo0.creator).to.be.equal(owner.address);

            const contract = await ethers.getContractAt("NFT", instance);
            expect(await contract.name()).to.be.equal(name);
            expect(await contract.symbol()).to.be.equal(symbol);
            expect(await contract.owner()).to.be.equal(owner.address);

        });
        
        describe("created instance test", async() => {
            const baseURI = "";
            const suffix = ".json";
            const price = ethers.utils.parseEther('1');
            const autoincrementPrice = ZERO;
            const now = Math.round(Date.now() / 1000);   
            const name = "NAME 1";
            const symbol = "SMBL1";
            const commissions = [
                ZERO,
                ZERO_ADDRESS
            ];
            const saleParams = [
                now + 100000, 
                ZERO_ADDRESS, 
                price,
                autoincrementPrice,
                ZERO, //ownerCommissionValue;
                ZERO  //authorCommissionValue;
            ];

            const seriesId = BigNumber.from('1000');
            const seriesParams = [
                alice.address,  
                10000,
                saleParams,
                commissions,
                baseURI,
                suffix
            ];
        
            

            beforeEach("listing series on sale", async() => {
                
                const NftFactory = await ethers.getContractFactory("NFT");
                await this.factory["produce(string,string,string)"](name, symbol, "");
                const hash = ethers.utils.solidityKeccak256(["string", "string"], [name, symbol]);
                const instance = await this.factory.getInstance(hash);
                //console.log('instance = ', instance);
                expect(instance).to.not.be.equal(ZERO_ADDRESS);
                this.nftCreatedByFactory = await NftFactory.attach(instance);
            })
            

            it("usual buy test", async() => {
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
                    autoincrementPrice,
                    ZERO, //ownerCommissionValue;
                    ZERO  //authorCommissionValue;
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

                await this.nftCreatedByFactory.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

                const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
                const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
                await this.nftCreatedByFactory.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price.mul(TWO)}); // accidentially send more than needed
                const balanceAfterBob = await ethers.provider.getBalance(bob.address);
                const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
                expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
                expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
                const newOwner = await this.nftCreatedByFactory.ownerOf(id);
                expect(newOwner).to.be.equal(bob.address);

                const tokenInfoData = await this.nftCreatedByFactory.tokenInfo(id);
                expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
                expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.price).to.be.equal(ZERO);
                expect(tokenInfoData.tokenInfo.salesInfoToken.saleInfo.onSaleUntil).to.be.equal(ZERO);
                expect(tokenInfoData.tokenInfo.salesInfoToken.ownerCommissionValue).to.be.equal(ZERO);
                expect(tokenInfoData.tokenInfo.salesInfoToken.authorCommissionValue).to.be.equal(ZERO);

                const seriesInfo = await this.nftCreatedByFactory.seriesInfo(seriesId);
                expect(seriesInfo.author).to.be.equal(alice.address);
                expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
                expect(seriesInfo.saleInfo.price).to.be.equal(price);
                expect(seriesInfo.saleInfo.autoincrement).to.be.equal(autoincrementPrice);
                expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
                expect(seriesInfo.baseURI).to.be.equal(baseURI);
                expect(seriesInfo.limit).to.be.equal(10000);

                    
            });
            
        });

        it("should correct several deploy instances", async() => {
            const names = ["NAME 1", "NAME 2", "NAME 3"];
            const symbols = ["SMBL1", "SMBL2", "SMBL3"];
            await this.factory["produce(string,string,string)"](names[0], symbols[0], "");
            await this.factory["produce(string,string,string)"](names[1], symbols[1], "");
            await this.factory["produce(string,string,string)"](names[2], symbols[2], "");

            expect(await this.factory.instancesCount()).to.be.equal(THREE);

            const hash1 = ethers.utils.solidityKeccak256(["string", "string"], [names[0], symbols[0]]);
            const hash2 = ethers.utils.solidityKeccak256(["string", "string"], [names[1], symbols[1]]);
            const hash3 = ethers.utils.solidityKeccak256(["string", "string"], [names[2], symbols[2]]);
            const instance1 = await this.factory.getInstance(hash1);
            const instance2 = await this.factory.getInstance(hash2);
            const instance3 = await this.factory.getInstance(hash3);
            // console.log('instance1 = ', instance1);
            // console.log('instance2 = ', instance2);
            // console.log('instance3 = ', instance3);

            expect(instance1).to.not.be.equal(ZERO_ADDRESS);
            expect(instance1).to.not.be.equal(instance2.address);
            expect(instance1).to.not.be.equal(instance3.address);

            expect(instance2).to.not.be.equal(ZERO_ADDRESS);
            expect(instance2).to.not.be.equal(instance3.address);

            expect(instance3).to.not.be.equal(ZERO_ADDRESS);

            const instanceInfo1 = await this.factory.getInstanceInfo(0);
            expect(instanceInfo1.name).to.be.equal(names[0]);
            expect(instanceInfo1.symbol).to.be.equal(symbols[0]);
            expect(instanceInfo1.creator).to.be.equal(owner.address);

            const instanceInfo2 = await this.factory.getInstanceInfo(1);
            expect(instanceInfo2.name).to.be.equal(names[1]);
            expect(instanceInfo2.symbol).to.be.equal(symbols[1]);
            expect(instanceInfo2.creator).to.be.equal(owner.address);

            const instanceInfo3 = await this.factory.getInstanceInfo(2);
            expect(instanceInfo3.name).to.be.equal(names[2]);
            expect(instanceInfo3.symbol).to.be.equal(symbols[2]);
            expect(instanceInfo3.creator).to.be.equal(owner.address);



        })

        it("shouldn't deploy instance with the existing name and symbol", async() => {
            await this.factory["produce(string,string,string)"]("NAME", "SMBL", "");
            await expect(this.factory["produce(string,string,string)"]("NAME", "SMBL", "")).to.be.revertedWith("Factory: ALREADY_EXISTS");
        })

        it("shouldn't deploy instance with empty name or symbol", async() => {
            await expect(this.factory["produce(string,string,string)"]("", "SMBL", "")).to.be.revertedWith("Factory: EMPTY NAME");
            await expect(this.factory["produce(string,string,string)"]("NAME", "", "")).to.be.revertedWith("Factory: EMPTY SYMBOL");
        })

    })
});