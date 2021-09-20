const BigNumber = require('bignumber.js');
const truffleAssert = require('truffle-assertions');

const NFTMock = artifacts.require("NFTMock");
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
    const twoToken = "2000000000000000000";
    const oneToken07 = "700000000000000000";
    const oneToken05 = "500000000000000000";    
    const oneToken03 = "300000000000000000";    
    var NFTMockInstance, CommunityMockInstance, ERC20MintableInstance;
    
    let tmpTr;
    
    before(async () => {
        CommunityMockInstance = await CommunityMock.new({ from: accountFive });
        NFTMockInstance = await NFTMock.new({ from: accountFive });
        await NFTMockInstance.initialize('NFT-title', 'NFT-symbol', [CommunityMockInstance.address, "members"], { from: accountFive });
        
        ERC20MintableInstance = await ERC20Mintable.new("erc20test","erc20test",{ from: accountFive });
    });

    it('should create ', async () => {
                                      //address token; uint256 amount;uint256 multiply;uint256 intervalSeconds;
        await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], {from: accountFive});
        
        await truffleAssert.reverts(
            NFTMockInstance.create("http://google.com", [zeroAddress, oneToken,0,0,7*3600,10000], {from: accountFive}),
            "NFT: Token address can not be zero"
        );
        
        await truffleAssert.reverts(
            NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,999999999], {from: accountFive}),
            "NFT: reduceCommission can be in interval [0;10000]"
        );

    });
    
    it('should become author and owner after create ', async () => {
                                      //address token; uint256 amount;uint256 multiply;uint256 intervalSeconds;
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], {from: accountFive});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 

        let author = await NFTMockInstance.authorOf(tokenID);
        let owner = await NFTMockInstance.ownerOf(tokenID);
        
        assert.isTrue((accountFive == author), "it was not become a author after creation");
        assert.isTrue((accountFive == owner), "it was not become a owner after creation");
        
    });

    it('should transfer Authorship', async () => {
        tmpTr = await await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], {from: accountFive});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        let authorOld = await NFTMockInstance.authorOf(tokenID);
        
        await truffleAssert.reverts(
            NFTMockInstance.authorOf(noneExistTokenID),
            'NFTBase: Nonexistent token'
        );
        
        //try to change author
        let authorNew = accountTwo;
        await truffleAssert.reverts(
            NFTMockInstance.transferAuthorship(authorNew, tokenID, {from: accountFourth}),
            'NFTAuthorship: sender is not author of token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.transferAuthorship(authorOld, tokenID, {from: authorOld}),
            'NFTAuthorship: transferAuthorship to current author'
        );
        
        await NFTMockInstance.transferAuthorship(authorNew, tokenID, {from: authorOld});
        
        let authorNewConfirm = await NFTMockInstance.authorOf(tokenID);
        assert.isTrue(
            (
                (authorOld != authorNew) &&
                (authorNew == authorNewConfirm)
            ), 
            "transferuthorship was failed"
        );
        
    });
  
    it('should transfer Ownership', async () => {
        tmpTr = await await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: accountFive});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        let ownerOld = await NFTMockInstance.ownerOf(tokenID);
        
        await truffleAssert.reverts(
            NFTMockInstance.ownerOf(noneExistTokenID),
            'ERC721: owner query for nonexistent token'
        );
        
        //try to change owner
        let ownerNew = accountOne;
        
        // imitate none-owner transfer
        await truffleAssert.reverts(
            NFTMockInstance.approve(ownerNew, tokenID, {from: accountFourth}),
            'ERC721: approve caller is not owner nor approved for all'
        );
       
        await NFTMockInstance.approve(ownerNew, tokenID, {from: ownerOld});
        await truffleAssert.reverts(
            NFTMockInstance.transferFrom(ownerOld, ownerNew, tokenID, {from: ownerOld}),
            "NFT: author's commission should be paid"
        );
        
        // mint oneToken and pay commission
        await ERC20MintableInstance.mint(accountFourth, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: accountFourth});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: accountFourth});
        
        // now try to transfer
        await NFTMockInstance.transferFrom(ownerOld, ownerNew, tokenID, {from: ownerOld});
        
        let ownerNewConfirm = await NFTMockInstance.ownerOf(tokenID);

        assert.isTrue(
            (
                (ownerOld != ownerNew) &&
                (ownerNew == ownerNewConfirm)
            ), 
            "transferOwnership was failed"
        );
        
    });

    it('reward to author:: (through 2 transfer, third have paid ) ', async () => {
        let author = accountFive;
        let owner1 = accountFive;
        let owner2 = accountTwo;
        let owner3 = accountThree;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: author});
        
        var tokenID = tmpTr.logs[0].args[1].toString();
        
        // transfer to new owner#2(accountTwo)

        // pay commission
        await ERC20MintableInstance.mint(accountFourth, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: accountFourth});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: accountFourth});
        
        // now try to transfer to new owner#2(accountTwo)
        await NFTMockInstance.approve(owner2, tokenID, {from: owner1});
        await NFTMockInstance.transferFrom(owner1, owner2, tokenID, {from: owner2});
        
        let balanceAuthorBefore = await ERC20MintableInstance.balanceOf(author);
        
        // pay commission again
        await ERC20MintableInstance.mint(accountFourth, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: accountFourth});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: accountFourth});
        
        // now try to transfer to new owner#2(accountThree)
        await NFTMockInstance.approve(owner3, tokenID, {from: owner2});
        await NFTMockInstance.transferFrom(owner2, owner3, tokenID, {from: owner3});
        
        let balanceAuthorAfter = await ERC20MintableInstance.balanceOf(author);
        
        assert.equal(
            (BigNumber(balanceAuthorAfter).minus(BigNumber(balanceAuthorBefore))).toString(), 
            BigNumber(oneToken).toString(), 
            'wrong rewards'
        );
        
    });
    
    it('reward to author:: (through 2 transfer, each next owner have paid ) ', async () => {
        let author = accountFive;
        let owner1 = accountFive;
        let owner2 = accountTwo;
        let owner3 = accountThree;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: author});
        
        var tokenID = tmpTr.logs[0].args[1].toString();
        
        // transfer to new owner#2(accountTwo)

        // pay commission
        await ERC20MintableInstance.mint(owner2, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: owner2});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: owner2});
        
        // now try to transfer to new owner#2(accountTwo)
        await NFTMockInstance.approve(owner2, tokenID, {from: owner1});
        await NFTMockInstance.transferFrom(owner1, owner2, tokenID, {from: owner2});
        
        let balanceAuthorBefore = await ERC20MintableInstance.balanceOf(author);
        
        // pay commission again
        await ERC20MintableInstance.mint(owner3, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: owner3});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: owner3});
        
        // now try to transfer to new owner#2(accountThree)
        await NFTMockInstance.approve(owner3, tokenID, {from: owner2});
        await NFTMockInstance.transferFrom(owner2, owner3, tokenID, {from: owner3});
        
        let balanceAuthorAfter = await ERC20MintableInstance.balanceOf(author);
        
        assert.equal(
            (BigNumber(balanceAuthorAfter).minus(BigNumber(balanceAuthorBefore))).toString(), 
            BigNumber(oneToken).toString(), 
            'wrong rewards'
        );
        
    });
    
    it('reward to author:: (through 2 transfer, several accounts have paid commission(current owner prefer in consume) ) ', async () => {
        let author = accountFive;
        let owner1 = accountFive;
        let owner2 = accountTwo;
        let owner3 = accountThree;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: author});
        
        var tokenID = tmpTr.logs[0].args[1].toString();
        
        // transfer to new owner#2(accountTwo)

        // pay commission
        await ERC20MintableInstance.mint(owner2, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: owner2});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: owner2});
        
        // now try to transfer to new owner#2(accountTwo)
        await NFTMockInstance.approve(owner2, tokenID, {from: owner1});
        await NFTMockInstance.transferFrom(owner1, owner2, tokenID, {from: owner2});
        
        
        // approve to transfer  to new owner#2(accountThree)
        await NFTMockInstance.approve(owner3, tokenID, {from: owner2});
        
        // pay commission again. owner will pay 0.7(OneToken) and some1 0.7(OneToken)
        await ERC20MintableInstance.mint(owner3, oneToken07);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken07, {from: owner3});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken07, {from: owner3});
        //------
        await truffleAssert.reverts(
            NFTMockInstance.transferFrom(owner2, owner3, tokenID, {from: owner3}),
            "NFT: author's commission should be paid"
        );
        //------
        await ERC20MintableInstance.mint(owner2, oneToken07);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken07, {from: owner2});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken07, {from: owner2});
        
        
        let balanceAuthorBefore = await ERC20MintableInstance.balanceOf(author);
        let balanceOwner3Before = await ERC20MintableInstance.balanceOf(owner3);
        let balanceOwner2Before = await ERC20MintableInstance.balanceOf(owner2);
        
        // now try to transfer  to new owner#2(accountThree)
        await NFTMockInstance.transferFrom(owner2, owner3, tokenID, {from: owner3});
        
        let balanceAuthorAfter = await ERC20MintableInstance.balanceOf(author);
        let balanceOwner3After = await ERC20MintableInstance.balanceOf(owner3);
        let balanceOwner2After = await ERC20MintableInstance.balanceOf(owner2);
        
        assert.equal(
            (BigNumber(balanceAuthorAfter).minus(BigNumber(balanceAuthorBefore))).toString(), 
            BigNumber(oneToken).toString(), 
            'wrong rewards'
        );
        
        assert.equal(
            (BigNumber(balanceOwner2Before).minus(BigNumber(balanceOwner2After))).toString(), 
            BigNumber(oneToken07).toString(), 
            'wrong consume by new owner'
        );
        
        assert.equal(
            BigNumber(balanceOwner3After).toString(), 
            (
                BigNumber(balanceOwner3Before).minus(
                    BigNumber(oneToken).minus(
                        BigNumber(balanceOwner2Before)
                    )
                )
            ).toString(), 
            'wrong consume by second paid-person'
        );
        
    });
    
    it('checking modifiers only for NFT Owners', async () => {
        let owner = accountFive;
        let anotherAccount = accountOne;
        tmpTr = await await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,10000], {from: owner});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        await truffleAssert.reverts(
            NFTMockInstance.listForSale(tokenID,oneToken,zeroAddress, {from: anotherAccount}),
            'NFTBase: Sender is not owner of token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.removeFromSale(tokenID, {from: anotherAccount}),
            'NFTBase: Sender is not owner of token'
        );
    });
    
    it('should buy NFT for coins(ETH)', async () => {
        let ownerOld = accountFive;
        let ownerNew = accountOne;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: ownerOld});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        // let put into sale-list for coins
        //await NFTMockInstance.listForSale(tokenID,oneToken,zeroAddress, {from: ownerOld});
        
        
        
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(noneExistTokenID, {from: ownerNew}),
            'NFTBase: Nonexistent token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            'NFT: Token does not in sale'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew}),
            'NFT: Token does not in sale'
        );
        
        // let put into sale-list for coins
        await NFTMockInstance.listForSale(tokenID,oneToken,zeroAddress, {from: ownerOld});
        
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            'NFT: Token can not be sale for tokens'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew}),
            'NFT: The coins sent are not enough'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew, value: oneToken07}),
            'NFT: The coins sent are not enough'
        );
        
        
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew, value: oneToken}),
            "NFT: author's commission should be paid"
        );
        
        
        // mint oneToken and pay commission
        await ERC20MintableInstance.mint(ownerNew, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: ownerNew});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: ownerNew});
        
        await NFTMockInstance.buy(tokenID, {from: ownerNew, value: oneToken});
        
        
        let ownerNewConfirm = await NFTMockInstance.ownerOf(tokenID);

        assert.isTrue(
            (
                (ownerOld != ownerNew) &&
                (ownerNew == ownerNewConfirm)
            ), 
            "buying for coins was failed"
        );
      
    });

    it('should buy NFT for tokens', async () => {
        let ownerOld = accountFive;
        let ownerNew = accountOne;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: ownerOld});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(noneExistTokenID, {from: ownerNew}),
            'NFTBase: Nonexistent token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            'NFT: Token does not in sale'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew}),
            'NFT: Token does not in sale'
        );
        
        // let put into sale-list for coins
        await NFTMockInstance.listForSale(tokenID,oneToken,ERC20MintableInstance.address, {from: ownerOld});
        
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew}),
            'NFT: Token can not be sale for coins'
        );
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            'NFT: The allowance tokens are not enough'
        );
       
        // mint two Tokens - one for buy and another one for commission
        await ERC20MintableInstance.mint(ownerNew, twoToken);
        // approve a half.  only for buy
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: ownerNew});
       
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            "NFT: author's commission should be paid"
        );
        
        // approve all, but not put in offer
        await ERC20MintableInstance.approve(NFTMockInstance.address, twoToken, {from: ownerNew});
        
        await truffleAssert.reverts(
            NFTMockInstance.buyWithToken(tokenID, {from: ownerNew}),
            "NFT: author's commission should be paid"
        );
        // put in offerToPay list
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: ownerNew});

        await NFTMockInstance.buyWithToken(tokenID, {from: ownerNew});
        
        let ownerNewConfirm = await NFTMockInstance.ownerOf(tokenID);

        assert.isTrue(
            (
                (ownerOld != ownerNew) &&
                (ownerNew == ownerNewConfirm)
            ), 
            "buying for coins was failed"
        );
        
    });
  
    it('getCommission: should validate params ', async () => {
        await truffleAssert.reverts(
            NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,0,10000], {from: accountFive}),
            'NFT: IntervalSeconds can not be zero'
        );
    });
    
    it('getCommission:  multiply predefined values (0 and 10000) ', async () => {
        
        let retTokenAddr,retCommission, tokenID;
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: accountFive});
        tokenID = tmpTr.logs[0].args[1].toString(); 
        
        tmpTr = await NFTMockInstance.getCommission(tokenID);
        retTokenAddr = tmpTr[0]; retCommission = tmpTr[1]; 
        
        assert.equal(
            retTokenAddr.toString(), 
            (ERC20MintableInstance.address).toString(), 
            "invalid address"
        );
        assert.equal(
            retCommission.toString(), 
            oneToken.toString(), 
            "wrong commission: multiply=0"
        );
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,10000,0,7*3600,0], {from: accountFive});
        tokenID = tmpTr.logs[0].args[1].toString(); 
        
        tmpTr = await NFTMockInstance.getCommission(tokenID);
        retTokenAddr = tmpTr[0]; retCommission = tmpTr[1]; 
       
        assert.equal(
            retCommission.toString(), 
            oneToken.toString(), 
            "wrong commission: multiply=10000"
        );
        
    });
    
    it('check getCommission: check with duration ', async () => {
        
        let ret, retCommission, tokenID, tokenID2;
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,15000,0,7*3600,0], {from: accountFive});
        tokenID = tmpTr.logs[0].args[1].toString();
        
        tmpTr = await NFTMockInstance.getCommission(tokenID);
        //retTokenAddr = tmpTr[0]; 
        retCommission = tmpTr[1]; 
        
        assert.equal(
            retCommission.toString(), 
            oneToken.toString(), 
            "wrong commission: multiply = 15000"
        );
        
        // forward to 5 times
        await helper.advanceTimeAndBlock(35*3602);
        tmpTr = await NFTMockInstance.getCommission(tokenID);
        retCommission = tmpTr[1]; 
        
        ret = BigNumber(oneToken);
        for (let i = 0; i < 5; i++) {
            ret = ret.times(BigNumber(15000)).div(BigNumber(10000));
        }

        assert.equal(
            retCommission.toString(), 
            ret.toString(), 
            "wrong commission: multiply = 15000, reduceCommission = 0%"
        );
        
        await truffleAssert.reverts(
            NFTMockInstance.reduceCommission(noneExistTokenID, 10000, {from: accountFive}),
            'NFTBase: Nonexistent token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.reduceCommission(tokenID, 10000, {from: accountOne}),
            'NFTAuthorship: sender is not author of token'
        );
        await truffleAssert.reverts(
            NFTMockInstance.reduceCommission(tokenID, 9999999999, {from: accountFive}),
            'NFT: reduceCommission can be in interval [0;10000]'
        );
        await NFTMockInstance.reduceCommission(tokenID, 10000, {from: accountFive});
        
        tmpTr = await NFTMockInstance.getCommission(tokenID);
        retCommission = tmpTr[1]; 
        
        assert.equal(
            retCommission.toString(), 
            '0', 
            "wrong commission: multiply = 15000, reduceCommission = 100%"
        );
        
    });
   
    it('check view calls', async () => {
        let ownerOld = accountFive;
        let ownerNew = accountOne;
        let tmpTr2;
        
        let localNFTMockInstance = await NFTMock.new({ from: accountFive });
        await localNFTMockInstance.initialize('NFT-title', 'NFT-symbol', [CommunityMockInstance.address, "members"], { from: accountFive });
        tmpTr = await localNFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: ownerOld});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 

        tmpTr = await localNFTMockInstance.getAllAuthors();
        tmpTr2 = await localNFTMockInstance.getAllOwners();

        assert.isTrue(
            (
                (tmpTr.length == tmpTr2.length) &&
                (tmpTr[0] == tmpTr2[0]) &&
                (tmpTr[0] == ownerOld)
            ), 
            "wrong getAllAuthors && getAllOwners"
        );
        
        tmpTr = await localNFTMockInstance.tokensByOwner(ownerOld);
        tmpTr2 = await localNFTMockInstance.tokensByAuthor(ownerOld);
        assert.isTrue(
            (
                (tmpTr.length == tmpTr2.length) &&
                (tmpTr[0].toString() == tmpTr2[0].toString()) &&
                (tmpTr[0].toString() == tokenID.toString())
            ), 
            "wrong tokensByOwner(ownerOld) && tokensByAuthor(ownerOld)"
        );
        
        tmpTr = await localNFTMockInstance.tokensByOwner(ownerNew);
        tmpTr2 = await localNFTMockInstance.tokensByAuthor(ownerNew);
        assert.isTrue(
            (
                (tmpTr.length == tmpTr2.length) &&
                (tmpTr.length == 0)
            ), 
            "wrong tokensByOwner(ownerNew) && tokensByAuthor(ownerNew)"
        );
        
        // let put into sale-list for coins
        await localNFTMockInstance.listForSale(tokenID,oneToken,zeroAddress, {from: ownerOld});
        
        // mint oneToken and pay commission
        await ERC20MintableInstance.mint(ownerNew, oneToken);
        await ERC20MintableInstance.approve(localNFTMockInstance.address, oneToken, {from: ownerNew});
        await localNFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: ownerNew});
        
        await localNFTMockInstance.buy(tokenID, {from: ownerNew, value: oneToken});
        
        
        let ownerNewConfirm = await localNFTMockInstance.ownerOf(tokenID);

        assert.isTrue(
            (
                (ownerOld != ownerNew) &&
                (ownerNew == ownerNewConfirm)
            ), 
            "buying for coins was failed"
        );
        
        
        tmpTr = await localNFTMockInstance.getAllAuthors();
        tmpTr2 = await localNFTMockInstance.getAllOwners();
        assert.isTrue(
            (
                (tmpTr.length == tmpTr2.length) &&
                (tmpTr[0] != tmpTr2[0]) &&
                (tmpTr[0] == ownerOld) &&
                (tmpTr2[0] == ownerNew)
            ), 
            "wrong getAllAuthors && getAllOwners"
        );
        
        tmpTr = await localNFTMockInstance.tokensByOwner(ownerOld);
        tmpTr2 = await localNFTMockInstance.tokensByAuthor(ownerOld);
        assert.isTrue(
            (
                (tmpTr.length != tmpTr2.length) &&
                (tmpTr.length == 0) &&
                (tmpTr2.length == 1) &&
                (tmpTr2[0] == tokenID.toString())
            ), 
            "wrong tokensByOwner(ownerOld) && tokensByAuthor(ownerOld)"
        );
        
        tmpTr = await localNFTMockInstance.tokensByOwner(ownerNew);
        tmpTr2 = await localNFTMockInstance.tokensByAuthor(ownerNew);
        assert.isTrue(
            (
                (tmpTr.length != tmpTr2.length) &&
                (tmpTr.length == 1) &&
                (tmpTr2.length== 0) &&
                (tmpTr[0] == tokenID.toString())
            ), 
            "wrong tokensByOwner(ownerNew) && tokensByAuthor(ownerNew)"
        );
        
        tmpTr = await localNFTMockInstance.historyOfBids(tokenID);
        assert.isTrue(
            (
                (tmpTr.length == 0)
            ), 
            "historyOfBids should be empty"
        );
      
    });
   
    it('auction full check (endtime = 0)', async () => {
        let ownerOld = accountFive;
        let ownerNew = accountOne;
        let ownerNew2 = accountTwo;
        let tmpTr2;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: ownerOld});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        // let put into sale-list for coins
        var startTime = 0;
        var endTime = 0;
        var minIncrement = oneToken;
        var pay1 = BigNumber(oneToken);
        var pay2 = BigNumber(oneToken).plus(BigNumber(minIncrement));
        var pay3 = BigNumber(oneToken).plus(BigNumber(minIncrement)).plus(BigNumber(minIncrement));
        
        await truffleAssert.reverts(
            NFTMockInstance.listForAuction(noneExistTokenID, oneToken,zeroAddress, startTime, endTime, minIncrement, {from: ownerOld}),
            "NFTBase: Nonexistent token"
        );
        await truffleAssert.reverts(
            NFTMockInstance.listForAuction(tokenID,oneToken,zeroAddress, startTime, endTime, minIncrement, {from: ownerNew}),
            "NFTBase: Sender is not owner of token"
        );
 
        await truffleAssert.reverts(
            NFTMockInstance.listForAuction(tokenID,oneToken,zeroAddress, 444, 222, minIncrement, {from: ownerOld}),
            "wrong startTime"
        );
        
        await NFTMockInstance.listForAuction(tokenID,oneToken,zeroAddress, startTime, endTime, minIncrement, {from: ownerOld});
        
        // mint oneToken and pay commission
        await ERC20MintableInstance.mint(ownerNew, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: ownerNew});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: ownerNew});
        
        
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew, value: pay1}),
            "bid should be more"
        );
        
        await NFTMockInstance.buy(tokenID, {from: ownerNew, value: pay2});
        
        let currentOwner = await NFTMockInstance.ownerOf(tokenID);
        assert.isTrue(
            (
                (currentOwner == ownerOld)
            ), 
            "auction is not complete yet"
        );
        
        await truffleAssert.reverts(
            NFTMockInstance.buy(tokenID, {from: ownerNew2, value: pay2}),
            "bid should be more"
        );
        
        await NFTMockInstance.buy(tokenID, {from: ownerNew2, value: pay3});
        
        tmpTr = await NFTMockInstance.historyOfBids(tokenID);
        assert.isTrue(
            (
                (tmpTr[0].bid == pay2) &&
                (tmpTr[1].bid == pay3)
            ), 
            "wrong history"
        );
        
        // still old owner 
        assert.isTrue(
            (
                ((await NFTMockInstance.ownerOf(tokenID)) == ownerOld)
            ), 
            "auction is not complete yet"
        );
        
        //try to claim another person
        await truffleAssert.reverts(
            NFTMockInstance.claim(tokenID, {from: ownerNew}),
            "can't claim"
        );
        
        //try to claim by winnerm but auction with endtime==0 can be accepting by nft owner only
        await truffleAssert.reverts(
            NFTMockInstance.claim(tokenID, {from: ownerNew2}),
            "can't claim"
        );
        
        await NFTMockInstance.acceptLastBid(tokenID, {from: ownerOld});
        
        assert.isTrue(
            (
                ((await NFTMockInstance.ownerOf(tokenID)) == ownerNew2)
            ), 
            "claim incorrect"
        );
        //console.log(tmpTr);
      
    });
    
    it('auction short check(endtime != 0)', async () => {
        let ownerOld = accountFive;
        let ownerNew = accountOne;
        let ownerNew2 = accountTwo;
        let tmpTr2;
        
        tmpTr = await NFTMockInstance.create("http://google.com", [ERC20MintableInstance.address, oneToken,0,0,7*3600,0], {from: ownerOld});
        
        var tokenID = tmpTr.logs[0].args[1].toString(); 
        
        // let put into sale-list for coins
        var startTime = 0;
        var getCurrTime = parseInt((await NFTMockInstance.getCurrTime()).toString());        

        var endTime = getCurrTime+60;
        var minIncrement = oneToken;
        var pay1 = BigNumber(oneToken);
        var pay2 = BigNumber(oneToken).plus(BigNumber(minIncrement));
        var pay3 = BigNumber(oneToken).plus(BigNumber(minIncrement)).plus(BigNumber(minIncrement));
        
        await NFTMockInstance.listForAuction(tokenID,oneToken,zeroAddress, startTime, endTime, minIncrement, {from: ownerOld});
        
        // mint oneToken and pay commission
        await ERC20MintableInstance.mint(ownerNew, oneToken);
        await ERC20MintableInstance.approve(NFTMockInstance.address, oneToken, {from: ownerNew});
        await NFTMockInstance.offerToPayCommission(tokenID, oneToken, {from: ownerNew});
        
        await NFTMockInstance.buy(tokenID, {from: ownerNew, value: pay2});
        
        await NFTMockInstance.buy(tokenID, {from: ownerNew2, value: pay3});
        
        await helper.advanceTimeAndBlock(300);
        
        //try to claim by winner
        await NFTMockInstance.claim(tokenID, {from: ownerNew2});
        
        assert.isTrue(
            (
                ((await NFTMockInstance.ownerOf(tokenID)) == ownerNew2)
            ), 
            "claim incorrect"
        );
        
      
    });
});