const BigNumber = require('bignumber.js');
const truffleAssert = require('truffle-assertions');

const NFTMock = artifacts.require("NFT");
const CommunityMock = artifacts.require("CommunityMock");
const ERC20Mintable = artifacts.require("ERC20Mintable");
const helper = require("../helpers/truffleTestHelper");

contract('NFT', (accounts) => {
    
    // Setup accounts.
    const accountOne = accounts[0];
    const accountTwo = accounts[1];
    const accountThree = accounts[2];
    const accountFourth = accounts[3];
    const accountFive = accounts[4];
    
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    
    const noneExistTokenID = '99999999';
    const oneToken = "1000000000000000000";
    
    const price_0_01 = "10000000000000000";
    
    var NFTMockInstance, CommunityMockInstance, ERC20MintableInstance;
    
    let tmpTr;
    
    before(async () => {
        CommunityMockInstance = await CommunityMock.new({ from: accountOne });
        NFTMockInstance = await NFTMock.new({ from: accountOne });
        await NFTMockInstance.initialize('NFT-title', 'NFT-symbol', [zeroAddress, "members"], { from: accountOne });
        
        ERC20MintableInstance = await ERC20Mintable.new("erc20test","erc20test",{ from: accountOne });
    });
    // beforeEach(async () => {
    // });
    
    it('[info]gas consuming ', async () => {
        
                                      //address token; uint256 amount;uint256 multiply;uint256 intervalSeconds;
        tmpTr = await NFTMockInstance.createAndListForSale("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], price_0_01, zeroAddress, {from: accountOne});
        
        
        var tokenID = tmpTr.logs[0].args[1].toString();
        
        let avgGasUsed={
            'listForSale': 0,
            'buy': 0,
            'transferFrom': 0
        };
        let countIterations = 10;
        for (let i=0; i<countIterations; i++) {
        if (i!= 0) {
            // let put into sale-list for coins
            tmpTr = await NFTMockInstance.listForSale(tokenID, price_0_01, zeroAddress, {from: accountOne});
            avgGasUsed['listForSale'] += tmpTr.receipt.gasUsed;
        }
            tmpTr = await NFTMockInstance.buy(tokenID, {from: accountTwo, value: price_0_01});
            avgGasUsed['buy'] += tmpTr.receipt.gasUsed;
            avgGasUsed['buy['+i+']'] /= tmpTr.receipt.gasUsed;

            tmpTr = await NFTMockInstance.listForSale(tokenID, price_0_01, zeroAddress, {from: accountTwo});
            avgGasUsed['listForSale'] += tmpTr.receipt.gasUsed;
            
            tmpTr = await NFTMockInstance.buy(tokenID, {from: accountOne, value: price_0_01});
            
        }
        
        avgGasUsed['listForSale'] /= countIterations;
        avgGasUsed['buy'] /= countIterations;
        avgGasUsed['transferFrom'] /= countIterations;
        
        console.log(avgGasUsed['listForSale']);
        console.log(avgGasUsed['buy']);
        console.log(avgGasUsed['transferFrom']);
        // assert.equal((avgGasUsed['listForSale']) < 80000, true, 'too much gas consuming `listForSale`');
        // assert.equal((avgGasUsed['buy']) < 80000, true, 'too much gas consuming `buy`');
        // assert.equal((avgGasUsed['transferFrom']) < 80000, true, 'too much gas consuming `transferFrom`');
    });
});