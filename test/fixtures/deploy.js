const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

async function deployBase() {
    const [
        owner, 
        alice, 
        bob, 
        charlie, 
        david, 
        eve,
        frank,
        buyer,
        commissionReceiver
    ] = await ethers.getSigners();

    

    const ReleaseManagerFactoryF = await ethers.getContractFactory("ReleaseManagerFactory");
    const ReleaseManagerF = await ethers.getContractFactory("ReleaseManager");
    const NFTFactoryF = await ethers.getContractFactory("NFTFactory");
    const NFTF = await ethers.getContractFactory("NFT");
    const NFTStateF = await ethers.getContractFactory("NFTState");
    const NFTViewF = await ethers.getContractFactory("NFTView");
    const CostManagerFactory = await ethers.getContractFactory("MockCostManager");
    const ERC20F = await ethers.getContractFactory("MockERC20");
    const BuyerF = await ethers.getContractFactory("Buyer");
    const CostManagerGoodF = await ethers.getContractFactory("MockCostManagerGood");
    const CostManagerBadF = await ethers.getContractFactory("MockCostManagerBad");
    const NFTSalesF = await ethers.getContractFactory("NFTSales");
    const NFTSalesFactoryF = await ethers.getContractFactory("NFTSalesFactory");
    const BadNFTSaleF = await ethers.getContractFactory("BadNFTSale");

    const HookF = await ethers.getContractFactory("MockHook");
    const BadHookF = await ethers.getContractFactory("MockBadHook");
    const FalseHookF = await ethers.getContractFactory("MockFalseHook");
    const NotSupportingHookF = await ethers.getContractFactory("MockNotSupportingHook");
    const WithoutFunctionHookF = await ethers.getContractFactory("MockWithoutFunctionHook");
    const MockCommunityF = await ethers.getContractFactory("MockCommunity");


    const nftState = await NFTStateF.deploy();
    const nftView = await NFTViewF.deploy();
    const nftImpl = await NFTF.deploy();
    const implementationReleaseManager = await ReleaseManagerF.deploy();
    const nftsale_implementation = await NFTSalesF.connect(owner).deploy();
    

    let releaseManagerFactory = await ReleaseManagerFactoryF.connect(owner).deploy(implementationReleaseManager.target);
    let tx,rc,event,instance,instancesCount;
    //
    tx = await releaseManagerFactory.connect(owner).produce();
    rc = await tx.wait(); // 0ms, as tx is already confirmed
    event = rc.logs.find(event => event.fragment && event.fragment.name === 'InstanceProduced');
    [instance, instancesCount] = event.args;
    const releaseManager = await ethers.getContractAt("ReleaseManager",instance);

    
    const TOTALSUPPLY = ethers.parseEther('1000000000');    
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
    const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';
    const contractURI = "https://contracturi";
    const SERIES_BITS = 192n;

    const costManager = await CostManagerFactory.deploy();

    const erc20 = await ERC20F.deploy("ERC20 Token", "ERC20");

    const costManagerGood = await CostManagerGoodF.deploy();
    const costManagerBad = await CostManagerBadF.deploy();

    const nftSaleFactory = await NFTSalesFactoryF.connect(owner).deploy(nftsale_implementation.target);
    const badNFTSale = await BadNFTSaleF.deploy();
   
    const hook1 = await HookF.deploy();
    const hook2 = await HookF.deploy();
    const hook3 = await HookF.deploy();
    const badHook = await BadHookF.deploy();
    const falseHook = await FalseHookF.deploy();
    const notSupportingHook = await NotSupportingHookF.deploy();
    const withoutFunctionHook = await WithoutFunctionHookF.deploy();
    const mockCommunity = await MockCommunityF.deploy();

    await erc20.mint(owner.address, TOTALSUPPLY);
    await erc20.connect(owner).transfer(alice.address, ethers.parseEther('100'));
    await erc20.connect(owner).transfer(bob.address, ethers.parseEther('100'));
    await erc20.connect(owner).transfer(charlie.address, ethers.parseEther('100'));
    await erc20.connect(owner).transfer(frank.address, ethers.parseEther('100'));
    await erc20.connect(owner).transfer(buyer.address, ethers.parseEther('100'));

    return {
        owner, 
        alice, 
        bob, 
        charlie, 
        david, 
        eve,
        frank,
        buyer,
        commissionReceiver,

        ReleaseManagerFactoryF,
        ReleaseManagerF,
        NFTFactoryF,
        NFTF,
        NFTStateF,
        NFTViewF,
        CostManagerFactory,
        ERC20F,
        BuyerF,
        NFTSalesF,
        NFTSalesFactoryF,
        HookF,
        BadHookF,
        FalseHookF,
        NotSupportingHookF,
        WithoutFunctionHookF,
        MockCommunityF,

        TOTALSUPPLY,
        ZERO_ADDRESS,
        DEAD_ADDRESS,
        contractURI,
        SERIES_BITS,

        nftState,
        nftView,
        nftImpl,
        releaseManager,
        
        costManager,
        erc20,
        costManagerGood,
        costManagerBad,
        nftsale_implementation,
        nftSaleFactory,
        badNFTSale,
        hook1,
        hook2,
        hook3,
        badHook,
        falseHook,
        notSupportingHook,
        withoutFunctionHook,
        mockCommunity
    }
}

async function deployFactoryWithCostManager () {
    const res = await loadFixture(deployBase);
    const {
        owner,

        NFTFactoryF,
        nftImpl, 
        nftState, 
        nftView,
        releaseManager,
        costManager
    } = res;

    const nftFactory = await NFTFactoryF.deploy(nftImpl.target, nftState.target, nftView.target, costManager, releaseManager.target);

    // 
    const factoriesList = [nftFactory.target];
    const factoryInfo = [
        [
            2,//uint8 factoryIndex; 
            2,//uint16 releaseTag; 
            "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
        ]
    ]
        
    await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);

    return {
        ...res,
        ...{
            nftFactory
        }
    }

}

async function deployFactoryWithoutCostManager () {
    const res = await loadFixture(deployBase);
    const {
        owner,
        NFTFactoryF,
        nftImpl, 
        nftState, 
        nftView,
        ZERO_ADDRESS, 
        releaseManager
    } = res;

    const nftFactory = await NFTFactoryF.deploy(nftImpl.target, nftState.target, nftView.target, ZERO_ADDRESS, releaseManager.target);

    // 
    const factoriesList = [nftFactory.target];
    const factoryInfo = [
        [
            2,//uint8 factoryIndex; 
            2,//uint16 releaseTag; 
            "0x53696c766572000000000000000000000000000000000000"//bytes24 factoryChangeNotes;
        ]
    ]
        
    await releaseManager.connect(owner).newRelease(factoriesList, factoryInfo);

    return {
        ...res,
        ...{
            nftFactory
        }
    }
}

async function deployNFT() {
    const res = await loadFixture(deployFactoryWithoutCostManager);
    const {
        owner,
        alice,
        commissionReceiver,
        bob,

        ZERO_ADDRESS,
        
        NFTF,
        BuyerF,
        nftFactory,
    } = res;

    //const seriesId = 1000n;
    const seriesId = BigInt(0x1000000000);
    const tokenId = 1n;
    const id = seriesId * (2n ** 192n) + (tokenId);
    const price = ethers.parseEther('1');
    const autoincrementPrice = 0n;
    const now = BigInt(Math.round(Date.now() / 1000));   
    const baseURI = "http://baseUri/";
    const suffix = ".json";
    const limit = 10000n;
    const saleParams = [
        now + 100000n, 
        ZERO_ADDRESS, 
        price,
        autoincrementPrice
    ];
    const commissions = [
        0n,
        ZERO_ADDRESS
    ];
    const seriesParams = [
        alice.address,  
        10000n,
        saleParams,
        commissions,
        baseURI,
        suffix
    ];

    /////////////////////////////////
    //--b
    const name = "NFT Edition";
    const symbol = "NFT";
    let tx,rc,event,instance;
    tx = await nftFactory.connect(owner)["produce(string,string,string)"](name, symbol, "");
    rc = await tx.wait();
    event = rc.logs.find(event => event.fragment && event.fragment.name === 'InstanceCreated');
    var [/*name*/, /*symbol*/, instanceAddr, /*instancesCount*/] = event.args;
    //let instanceAddr = rc['events'][0].args.instance;

    const nft = await NFTF.attach(instanceAddr);
    //--e

    await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
    const retval = '0x150b7a02';
    const error = 0n;
    const buyerContract = await BuyerF.deploy(retval, error);

    const FRACTION = 10000n;
    const TEN_PERCENTS = 10n * (FRACTION) / (100n);//BigNumber.from('10000');
    const FIVE_PERCENTS = 5n * (FRACTION) / (100n);//BigNumber.from('5000');
    const ONE_PERCENT = 1n * (FRACTION) / (100n);//BigNumber.from('1000');
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

    return {
        ...res,
        ...{
            seriesId,
            tokenId,
            id,
            price,
            autoincrementPrice,
            now,
            baseURI,
            suffix,
            limit,
            saleParams,
            commissions,
            seriesParams,
            name,
            symbol,

            FRACTION,
            TEN_PERCENTS,
            FIVE_PERCENTS,
            ONE_PERCENT,
            seriesCommissions,
            maxValue,
            minValue,
            defaultCommissionInfo,


            nft,
            buyerContract,
        }
    };

}

async function deployNFTSale() {
    const res = await loadFixture(deployNFT);
    var {
        owner,
        alice,
        bob,
        charlie,

        ZERO_ADDRESS,
        //---
        seriesId,
        tokenId,
        baseURI,
        saleParams,
        commissions,
        suffix,
        //---
        nft,
        NFTSalesF,
        nftSaleFactory
        
    } = res;

    
    //override params
    tokenId = 10n;
    baseURI = "http://baseUri/";
    id = seriesId * (2n ** 192n) + (tokenId);

    seriesParams = [
        alice.address,  
        10000,
        saleParams,
        commissions,
        baseURI,
        suffix
    ];

    
    
    await nft.connect(owner).setTrustedForwarder(nftSaleFactory.target);

    const nft_day_duration = 6n;
    let tx = await nftSaleFactory.connect(owner).produce(
        nft.target,   // address nftAddress,
        seriesId,           // uint64 seriesId,
        bob.address,        // address owner, 
        ZERO_ADDRESS,       // address currency, 
        ethers.parseEther('1'),            // uint256 price, 
        bob.address,        // address beneficiary, 
        1n,                // uint192 autoIndex,
        nft_day_duration * (24n*60n*60n),  // uint64 duration
        10n,                // uint32 rateInterval,
        10n                 // uint16 rateAmount
        
    ) 

    let rc = await tx.wait();
    let event = rc.logs.find(event => event.fragment && event.fragment.name === 'InstanceCreated');
    var [instanceAddr] = event.args;
    const nftsale = await NFTSalesF.attach(instanceAddr);

    await nftsale.connect(bob).setAllowTransfers(true);

    await nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);

    return {
        ...res,
        ...{
            tokenId,
            baseURI,
            id,
            nft_day_duration,
            nftsale
        }
    };

}

module.exports = {
    deployBase,
    deployFactoryWithCostManager,
    deployFactoryWithoutCostManager,
    deployNFT,
    deployNFTSale,
//   deployWithoutDelay,
//   deployWithDelay,
//   deploy,
//   deployForTimetests,
//   deployForTokensTransfer
}