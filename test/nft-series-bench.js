const BigNumber = require('bignumber.js');
const truffleAssert = require('truffle-assertions');
const helperCostEth = require("../helpers/transactionsCost");

const NFTSeriesMock = artifacts.require("NFTSeriesMock");
const CommunityMock = artifacts.require("CommunityMock");
const ERC20Mintable = artifacts.require("ERC20Mintable");
const helper = require("../helpers/truffleTestHelper");

contract('NFTSeries Bench', (accounts) => {
    
    // Setup accounts.
    const accountOne = accounts[0];
    const accountTwo = accounts[1];
    const accountThree = accounts[2];
    const accountFourth = accounts[3];
    const accountFive = accounts[4];
    
    const zeroAddress = "0x0000000000000000000000000000000000000000";
    
    const noneExistTokenID = '99999999';
    const oneToken = "1000000000000000000";
    const twoToken = "2000000000000000000";
    const oneToken07 = "700000000000000000";
    const oneToken05 = "500000000000000000";    
    const oneToken03 = "300000000000000000";    
	
	const amountTokensToCreate = 50;
    var NFTSeriesMockInstance, CommunityMockInstance, ERC20MintableInstance;
    helperCostEth.transactionsClear();
    
    let tmpTr;
    function getArgs(tr, eventname) {
        for (var i in tmpTr.logs) {
            if (eventname == tmpTr.logs[i].event) {
                return tmpTr.logs[i].args;
            }
        }
        return '';
    }
    before(async () => {
        CommunityMockInstance = await CommunityMock.new({ from: accountFive });
        NFTSeriesMockInstance = await NFTSeriesMock.new({ from: accountFive });
        await NFTSeriesMockInstance.initialize('NFT-title', 'NFT-symbol', [CommunityMockInstance.address, "members"], { from: accountFive });
        
        ERC20MintableInstance = await ERC20Mintable.new("erc20test","erc20test",{ from: accountFive });
    });
    // beforeEach(async () => {
    // });
  /*  
    it('test gas cost while create ', async () => {
        
        let accounts = [accountFourth, accountFive];
        let counts = [10,20,50,100,500,1000,5000,10000,50000,100000,500000];
        let avgGasUsed = 0;
        let avgGasUsedExpectHigh = 430000;
        for(let j = 0; j < accounts.length; j++) {
            for(let i = 0; i < counts.length; i++) {
                trTmp = await NFTSeriesMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], counts[i], {from: accounts[j]});
                helperCostEth.transactionPush(trTmp, 'account #'+j+': create '+counts[i]+' tokens; ');
                avgGasUsed += trTmp.receipt.gasUsed;
            }
        }
        

        avgGasUsed = avgGasUsed/(counts.length*accounts.length);
        
        assert.equal(
            avgGasUsedExpectHigh>avgGasUsed, 
            true, 
            "high gas costs"
        );
        
        
        
        // trTmp = await NFTSeriesMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], 100, {from: accountFive});
        // helperCostEth.transactionPush(trTmp, 'accountFive: create '+100+' tokens; ');
        
    });
*/
    it('test gas cost while transfer ', async () => {
        
        await NFTSeriesMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,1,1,7*3600,10000], 100, {from: accountFourth});
        trTmp = await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 50, {from: accountFourth});
        helperCostEth.transactionPush(trTmp, 'transfer in series 1 split in 1 range');
//console.log(trTmp.logs[0].args);        
//console.log(trTmp.logs[0].args[0].toString());        
        
        await NFTSeriesMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], 100, {from: accountFourth});
        
        await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 125, {from: accountFourth});
        await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 150, {from: accountFourth});
        await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 175, {from: accountFourth});
        // 100-124;125-125;126-149;150-150;151-174;175-175;176-199
        trTmp = await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 180, {from: accountFourth});
        helperCostEth.transactionPush(trTmp, 'transfer in series 2 split in 7 range');
        
        await NFTSeriesMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], 100, {from: accountFourth});
        for(let i=202; i< 295; i++) {
            await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, i, {from: accountFourth});    
        }
        trTmp = await NFTSeriesMockInstance.transferFrom(accountFourth, accountFive, 298, {from: accountFourth});
        helperCostEth.transactionPush(trTmp, 'transfer in series 3 split in ~100 range');
        
        
        
        
    });

    it('summary transactions cost', async () => {
        
        console.table(await helperCostEth.getTransactionsCostEth(90, false));

    });
    /**/
 });