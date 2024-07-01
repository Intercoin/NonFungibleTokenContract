const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

async function deployBase() {
    const [
        owner, 
        alice, 
        bob, 
        charlie, 
        david, 
        eve,
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

    const nftState = await NFTStateF.deploy();
    const nftView = await NFTViewF.deploy();
    const nftImpl = await NFTF.deploy();
    const implementationReleaseManager = await ReleaseManagerF.deploy();

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

    return {
        owner, 
        alice, 
        bob, 
        charlie, 
        david, 
        eve,

        ReleaseManagerFactoryF,
        ReleaseManagerF,
        NFTFactoryF,
        NFTF,
        NFTStateF,
        NFTViewF,
        CostManagerFactory,
        ERC20F,
        BuyerF,

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

module.exports = {
    deployBase,
    deployFactoryWithCostManager,
    deployFactoryWithoutCostManager
//   deployWithoutDelay,
//   deployWithDelay,
//   deploy,
//   deployForTimetests,
//   deployForTokensTransfer
}