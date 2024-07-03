const { ethers} = require('hardhat');
const { expect } = require('chai');
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

require("@nomicfoundation/hardhat-chai-matchers");

const { 
    deployNFTSale
} = require("./fixtures/deploy.js");

// const OPERATION_INITIALIZE = 0;
// const OPERATION_SETMETADATA = 1;
// const OPERATION_SETSERIESINFO = 2;
// const OPERATION_SETOWNERCOMMISSION = 3;
// const OPERATION_SETCOMMISSION = 4;
// const OPERATION_REMOVECOMMISSION = 5;
// const OPERATION_LISTFORSALE = 6;
// const OPERATION_REMOVEFROMSALE = 7;
// const OPERATION_MINTANDDISTRIBUTE = 8;
// const OPERATION_BURN = 9;
// const OPERATION_BUY = 10;
// const OPERATION_TRANSFER = 11;


describe("nftsale tests", function () {
    
    it("instancesCount check ", async() => {
        const res = await loadFixture(deployNFTSale);
        const {
            nftSaleFactory
        } = res;

        expect(await nftSaleFactory.instancesCount()).to.be.eq(1n);
    });  

    it("bob should be owner of nftsale", async() => {
        const res = await loadFixture(deployNFTSale);
        const {
            bob,
            nftsale
        } = res;
        
        const nftsale_owner = await nftsale.owner();
        expect(nftsale_owner).to.be.eq(bob.address);
    });  

    // const res = await loadFixture(deployNFT);
    // const {
    //     alice,
    //     bob,
    //     id,
    //     ZERO_ADDRESS,
    //     price,
    //     baseURI,
    //     now,
    //     seriesId,
    //     autoincrementPrice,
    //     nft
    // } = res;
    

    describe("put series into sale", async() => {
            
        it("should't special purchase without whitelist ", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                id,
                charlie,
                price,
                nftsale
            } = res;
            await expect(
                nftsale.connect(charlie).specialPurchase(id, [charlie.address], {value: price * 2n})
            ).to.be.revertedWithCustomError(nftsale, 'NotInWhiteList').withArgs(charlie.address);
            // accidentially send more than needed
        });  

        it("should't special purchase from none-instance(another external contract) call", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                id,
                charlie,
                price,
                nftSaleFactory,
                badNFTSale
            } = res;

            
            await expect(
                badNFTSale.connect(charlie).specialPurchase(nftSaleFactory.target, [id], [charlie.address], {value: price * 2n})
            ).to.be.revertedWithCustomError(nftSaleFactory, 'InstancesOnly');
            // accidentially send more than needed
        });  


        it("should't special purchase if factory's owner have remove nftsale instance from whitelist ", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                owner,
                bob,
                charlie,
                price,
                nftsale,
                nftSaleFactory
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])

            //await nftsaleFactory.connect(owner).addToBlackList(nftsale.target);
            //--- make sure that instance is not in whitelist, so just try to remove
            await nftSaleFactory.connect(owner).removeFromWhiteList(nftsale.target);
            //----
            await expect(
                nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n})
            ).to.be.revertedWithCustomError(nftSaleFactory, 'InstancesOnly');
        });  

        it("should't special purchase if factory's owner remove nftsale instance from blacklist ", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                owner,
                bob,
                charlie,
                price,
                nftsale,
                nftSaleFactory
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])

            await nftSaleFactory.connect(owner).removeFromWhiteList(nftsale.target);

            await expect(
                nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n})
            ).to.be.revertedWithCustomError(nftSaleFactory, 'InstancesOnly');

            /*
            // uncomment and adapted this code when factory be able to push instance to whitelist back
            await nftsaleFactory.connect(owner).removeFromBlackList(nftsale.target);

            await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});
            
            expect(await nft.ownerOf(id)).to.be.eq(nftsale.target);
            expect(await nft.ownerOf(id)).not.to.be.eq(charlie.address);

            // jump forvard to an hour
            await network.provider.send("evm_mine", [await now() + 3600]);

            await expect(nftsale.connect(alice).distributeUnlockedTokens([id])).to.be.revertedWith("Tokens can be claimed after " + nft_day_duration.sub(1n) + " more days.")

            // jump forvard to end period 
            await network.provider.send("evm_mine", [await now() + parseInt(nft_day_duration.mul(86400))]);
            
            await nftsale.connect(alice).distributeUnlockedTokens([id]);

            expect(await nft.ownerOf(id)).not.to.be.eq(nftsale.target);
            expect(await nft.ownerOf(id)).to.be.eq(charlie.address);
            */

        }); 

        it("should special purchase ", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                bob,
                charlie,
                price,
                nftsale
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])
            await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});

        });  

        it("should locked up token after special purchase ", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                bob,
                charlie,
                price,
                nft_day_duration,
                nft,
                nftsale
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])
            let tx = await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});
            let rc = await tx.wait();

            let transferredToken = rc.logs[0].topics[3];
            // @dev here two txs: 
            // 1 - in NFTcontract transfer tokenID from zero to NFTsale (as pending for recipient)
            // 2 - in NFTSale transfer tokenID from zero to recipient.
            // in boths tokenId the same so we can touch any tx
            
            expect(await nft.ownerOf(transferredToken)).to.be.eq(nftsale.target);
            expect(await nft.ownerOf(transferredToken)).not.to.be.eq(charlie.address);

            // jump forvard to an hour
            await time.increase(3600);
            
            // // after locking to and six day, and waiting for an hour -> remainingDays will return five days left
            // expect(await nftsale.remainingDays(transferredToken)).to.be.eq(nft_day_duration.sub(1n));
            //[UPD] after new fixes, remainingDays will return "day plus one". for example if 2 hours left - method will return 1 day instead 0 day.  and so on
            expect(await nftsale.remainingDays(transferredToken)).to.be.eq(nft_day_duration);

        });  

        it("should distributeUnlockedTokens", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                alice,
                bob,
                charlie,
                price,
                nft,
                nftsale,
                nft_day_duration
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])
            let tx = await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});
            let rc = await tx.wait();
            let transferredToken = rc.logs[0].topics[3];
            // let purchasedBlockTime = await rc.events[0].getBlock();
            // let expectedTimestamp = BigNumber.from(purchasedBlockTime.timestamp).add(86400*6); // six day
            
            // jump forvard to an hour
            await time.increase(3600);

            //await expect(nftsale.connect(alice).distributeUnlockedTokens([id])).to.be.revertedWith("Tokens can be claimed after " + nft_day_duration.sub(1n) + " more days.")
            await expect(nftsale.connect(alice).distributeUnlockedTokens([transferredToken])).to.be.revertedWithCustomError(nftsale, 'StillPending').withArgs(6, nft_day_duration * 86400n - 3600n - 1n);

            //UnknownTokenIdForClaim(${transferredToken})

            // jump forvard to end period 
            await time.increase(nft_day_duration*86400n);
            
            await nftsale.connect(alice).distributeUnlockedTokens([transferredToken]);

            expect(await nft.ownerOf(transferredToken)).not.to.be.eq(nftsale.target);
            expect(await nft.ownerOf(transferredToken)).to.be.eq(charlie.address);
            
        }); 
        
        it("should claim", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                alice,
                bob,
                charlie,
                price,
                nft,
                nftsale,
                nft_day_duration
            } = res;

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])
            let tx = await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});
            let rc = await tx.wait();
            let transferredToken = rc.logs[0].topics[3];

            // jump forvard to an hour
            await time.increase(3600n);

            //await expect(nftsale.connect(alice).claim([id])).to.be.revertedWith("Tokens can be claimed after " + nft_day_duration.sub(1n) + " more days.");
            await expect(
                nftsale.connect(alice).claim([transferredToken])
            ).to.be.revertedWithCustomError(nftsale, 'StillPending').withArgs(6, 6n * 86400n - 3600n - 1n);
            

            // jump forvard to end period 
            await time.increase(nft_day_duration*86400n);
            
            await expect(nftsale.connect(alice).claim([transferredToken])).to.be.revertedWithCustomError(nftsale, 'ShouldBeTokenOwner').withArgs(alice.address);

            await nftsale.connect(charlie).claim([transferredToken]);

            expect(await nft.ownerOf(transferredToken)).not.to.be.eq(nftsale.target);
            expect(await nft.ownerOf(transferredToken)).to.be.eq(charlie.address);
            
        }); 

        it("should't transfer if `allowTransfers` disabled", async() => {
            const res = await loadFixture(deployNFTSale);
            const {
                alice,
                bob,
                charlie,
                price,
                nft,
                nftsale
            } = res;
            

            await nftsale.connect(bob).specialPurchasesListAdd([charlie.address])

            let tx = await nftsale.connect(charlie).specialPurchase(1n, [charlie.address], {value: price * 2n});
            let rc = await tx.wait();
            let transferredToken = rc.logs[0].topics[3];

            // jump forvard to an hour
            await time.increase(3600n);


            await nftsale.connect(charlie).transferFrom(charlie.address, bob.address, transferredToken);
            expect(await nftsale.connect(alice).ownerOf(transferredToken)).to.be.eq(bob.address);
            expect(await nft.ownerOf(transferredToken)).to.be.eq(nftsale.target);

            await nftsale.connect(bob).setAllowTransfers(false);

            await expect(nftsale.connect(bob).transferFrom(bob.address, alice.address, transferredToken)).to.be.revertedWithCustomError(nftsale, 'NoTransfersAllowed');
            expect(await nft.ownerOf(transferredToken)).to.be.eq(nftsale.target);

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

