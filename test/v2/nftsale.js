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
const FOUR = BigNumber.from('4');
const FIVE = BigNumber.from('5');
const SIX = BigNumber.from('6');
const SEVEN = BigNumber.from('7');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const ONE_ETH = ethers.utils.parseEther('1');    

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
    
describe("nftsale tests", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];
    const commissionReceiver = accounts[4];

    beforeEach("deploying", async() => {
        const ERC20Factory = await ethers.getContractFactory("MockERC20");
        const NFTMainFactory = await ethers.getContractFactory("NFTMain");
        const NFTStateFactory = await ethers.getContractFactory("NFTState");
        const NFTViewFactory = await ethers.getContractFactory("NFTView");

        const HookFactory = await ethers.getContractFactory("MockHook");
        const BadHookFactory = await ethers.getContractFactory("MockBadHook");
        const FalseHookFactory = await ethers.getContractFactory("MockFalseHook");
        const NotSupportingHookFactory = await ethers.getContractFactory("MockNotSupportingHook");
        const WithoutFunctionHookFactory = await ethers.getContractFactory("MockWithoutFunctionHook");
        const BuyerFactory = await ethers.getContractFactory("Buyer");
        const BadBuyerFactory = await ethers.getContractFactory("BadBuyer");
        const CostManagerFactory = await ethers.getContractFactory("MockCostManager");
        const MockCommunityFactory = await ethers.getContractFactory("MockCommunity");

        this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
        this.hook1 = await HookFactory.deploy();
        this.hook2 = await HookFactory.deploy();
        this.hook3 = await HookFactory.deploy();
        this.badHook = await BadHookFactory.deploy();
        this.falseHook = await FalseHookFactory.deploy();
        this.notSupportingHook = await NotSupportingHookFactory.deploy();
        this.withoutFunctionHook = await WithoutFunctionHookFactory.deploy();
        this.nftState = await NFTStateFactory.deploy();
        this.nftView = await NFTViewFactory.deploy();

        this.costManager = await CostManagerFactory.deploy();
        this.mockCommunity = await MockCommunityFactory.deploy();
        

        const retval = '0x150b7a02';
        const error = ZERO;
        this.buyer = await BuyerFactory.deploy(retval, error);
        this.badBuyer = await BadBuyerFactory.deploy();
        this.nft = await NFTMainFactory.deploy();

        await this.nft.connect(owner).initialize(this.nftState.address, this.nftView.address,"NFT Edition", "NFT", "", "", "", this.costManager.address, ZERO_ADDRESS);

        await this.erc20.mint(owner.address, TOTALSUPPLY);

        await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(charlie.address, ethers.utils.parseEther('100'));

        //-------------------------------------------------------------------
        const NFTSalesF = await ethers.getContractFactory("NFTSales");
        const NFTSalesFactoryF = await ethers.getContractFactory("NFTSalesFactory");

        this.nftsale_implementation = await NFTSalesF.connect(owner).deploy();
        this.nftSaleFactory = await NFTSalesFactoryF.connect(owner).deploy(this.nftsale_implementation.address);

        await this.nft.connect(owner).setTrustedForwarder(this.nftSaleFactory.address);

        this.nft_day_duration = SIX;
        let tx = await this.nftSaleFactory.connect(owner).produce(
            this.nft.address,   // address nftAddress,
            bob.address,        // address owner, 
            ZERO_ADDRESS,       // address currency, 
            ONE_ETH,            // uint256 price, 
            bob.address,        // address beneficiary, 
            this.nft_day_duration.mul(24*60*60)  // uint64 duration
        ) 

        let receipt = await tx.wait();
        let instanceAddr = receipt['events'][0].args.instance; "InstanceCreated"

        this.nftsale = await NFTSalesF.attach(instanceAddr);

    })

    
    it("instancesCount check ", async() => {
        expect(await this.nftSaleFactory.instancesCount()).to.be.eq(ONE);
    });  

    it("bob should be owner of nftsale", async() => {
        //expect(1).to.be.eq(1);
        const nftsale_owner = await this.nftsale.owner();
        expect(nftsale_owner).to.be.eq(bob.address);
    });  


    describe("put series into sale", async() => {
        const seriesId = BigNumber.from('1000');
        const tokenId = TEN;
        
        const price = ethers.utils.parseEther('1');
        const now = Math.round(Date.now() / 1000);   
        const baseURI = "";
        const suffix = ".json";
        const saleParams = [
            now + 100000, 
            ZERO_ADDRESS, 
            price,
            ZERO //autoincrement price
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

        beforeEach("put into sale", async() => {
            await this.nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
        });

        describe("test", async() => {
            var now = async function(){
                return parseInt((await ethers.provider.getBlock(await ethers.provider.getBlockNumber())).timestamp);
            }
            var id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
            var snapId;

            beforeEach("deploying", async() => {
                // make snapshot before time manipulations
                snapId = await ethers.provider.send('evm_snapshot', []);
            });

            afterEach("deploying", async() => {
                // restore snapshot
                await ethers.provider.send('evm_revert', [snapId]);
            });
            
            it("should't special purchase without whitelist ", async() => {
                await expect(
                    this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)})
                ).to.be.revertedWith("Sender is not in whitelist");
                // accidentially send more than needed
            });  

            it("should't special purchase from none-instance(another external contract) call", async() => {
                const BadNFTSaleF = await ethers.getContractFactory("BadNFTSale");
                let badNFTSale = await BadNFTSaleF.deploy();

                await expect(
                    badNFTSale.connect(charlie).specialPurchase(this.nftSaleFactory.address, [id], [charlie.address], {value: price.mul(TWO)})
                ).to.be.revertedWith("instances only");
                // accidentially send more than needed
            });  
            

            it("should't special purchase if factory's owner have put nftsale instance into blacklist ", async() => {
                await this.nftsale.connect(bob).whitelistAdd([charlie.address])

                await this.nftSaleFactory.connect(owner).addToBlackList(this.nftsale.address);

                await expect(
                    this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)})
                ).to.be.revertedWith("instance in black list");
            });  

            it("should't special purchase if factory's owner remove nftsale instance from blacklist ", async() => {
                await this.nftsale.connect(bob).whitelistAdd([charlie.address])

                await this.nftSaleFactory.connect(owner).addToBlackList(this.nftsale.address);

                await expect(
                    this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)})
                ).to.be.revertedWith("instance in black list");

                await this.nftSaleFactory.connect(owner).removeFromBlackList(this.nftsale.address);

                await this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)});
                
                expect(await this.nft.ownerOf(id)).to.be.eq(this.nftsale.address);
                expect(await this.nft.ownerOf(id)).not.to.be.eq(charlie.address);

                // jump forvard to an hour
                await network.provider.send("evm_mine", [await now() + 3600]);

                await expect(this.nftsale.connect(alice).distributeUnlockedTokens([id])).to.be.revertedWith("Tokens can be claimed after " + this.nft_day_duration.sub(ONE) + " more days.")

                // jump forvard to end period 
                await network.provider.send("evm_mine", [await now() + parseInt(this.nft_day_duration.mul(86400))]);
                
                await this.nftsale.connect(alice).distributeUnlockedTokens([id]);

                expect(await this.nft.ownerOf(id)).not.to.be.eq(this.nftsale.address);
                expect(await this.nft.ownerOf(id)).to.be.eq(charlie.address);

            }); 

            it("should special purchase ", async() => {
                await this.nftsale.connect(bob).whitelistAdd([charlie.address])
                await this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)});

            });  

            it("should locked up token after special purchase ", async() => {

                await this.nftsale.connect(bob).whitelistAdd([charlie.address])
                await this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)});
                
                expect(await this.nft.ownerOf(id)).to.be.eq(this.nftsale.address);
                expect(await this.nft.ownerOf(id)).not.to.be.eq(charlie.address);

                // jump forvard to an hour
                await network.provider.send("evm_mine", [await now() + 3600]);

                // after locking to and six day, and waiting for an hour -> remainingDays will return five days left
                expect(await this.nftsale.remainingDays(id)).to.be.eq(this.nft_day_duration.sub(ONE));

            });  

            it("should distributeUnlockedTokens", async() => {

                await this.nftsale.connect(bob).whitelistAdd([charlie.address])
                await this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)});

                // jump forvard to an hour
                await network.provider.send("evm_mine", [await now() + 3600]);

                await expect(this.nftsale.connect(alice).distributeUnlockedTokens([id])).to.be.revertedWith("Tokens can be claimed after " + this.nft_day_duration.sub(ONE) + " more days.")

                // jump forvard to end period 
                await network.provider.send("evm_mine", [await now() + parseInt(this.nft_day_duration.mul(86400))]);
                
                await this.nftsale.connect(alice).distributeUnlockedTokens([id]);

                expect(await this.nft.ownerOf(id)).not.to.be.eq(this.nftsale.address);
                expect(await this.nft.ownerOf(id)).to.be.eq(charlie.address);
                
            }); 
            
            it("should claim", async() => {

                await this.nftsale.connect(bob).whitelistAdd([charlie.address])
                await this.nftsale.connect(charlie).specialPurchase([id], [charlie.address], {value: price.mul(TWO)});

                // jump forvard to an hour
                await network.provider.send("evm_mine", [await now() + 3600]);

                await expect(this.nftsale.connect(alice).claim([id])).to.be.revertedWith("Tokens can be claimed after " + this.nft_day_duration.sub(ONE) + " more days.")

                // jump forvard to end period 
                await network.provider.send("evm_mine", [await now() + parseInt(this.nft_day_duration.mul(86400))]);
                
                await expect(this.nftsale.connect(alice).claim([id])).to.be.revertedWith("should be owner")

                await this.nftsale.connect(charlie).claim([id]);



                expect(await this.nft.ownerOf(id)).not.to.be.eq(this.nftsale.address);
                expect(await this.nft.ownerOf(id)).to.be.eq(charlie.address);
                
            }); 



        });  
    });  
    
    


    //it("", async() => {});  
    //it("", async() => {});  
    //it("", async() => {});  
    //it("", async() => {});  
    //it("", async() => {});  
    //it("", async() => {});  

    //it("", async() => {});  

})
})
