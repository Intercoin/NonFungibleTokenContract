const { ethers} = require('hardhat');
const { expect } = require('chai');
const { time, loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

require("@nomicfoundation/hardhat-chai-matchers");

const { 
    deployNFT
} = require("./fixtures/deploy.js");

const { 
    toHexString
} = require("./helpers/toHexString.js");


describe("Standart ERC721 functional tests", function () {

    describe('transfer tests', async() => {
    
        it('check name, symbol and tokenURI', async() => {

            const res = await loadFixture(deployNFT);
            const {
                alice,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;
            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address, {value: price}); 
            //console.log("await nft.tokenURI(id) = ", await nft.tokenURI(id));
            
            expect(await nft.tokenURI(id)).to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));
            expect(await nft.name()).to.be.equal("NFT Edition");
            expect(await nft.symbol()).to.be.equal("NFT");
        })
        it('check name and symbol after owner set', async() => {
            const res = await loadFixture(deployNFT);
            const {
                owner,
                alice,
                nft
            } = res;

            await expect(nft.connect(alice).setNameAndSymbol("NEW NFT Edition", "NEW NFT")).to.be.revertedWith("Ownable: caller is not the owner");
            await nft.connect(owner).setNameAndSymbol("NEW NFT Edition", "NEW NFT"); 
            expect(await nft.name()).to.be.equal("NEW NFT Edition");
            expect(await nft.symbol()).to.be.equal("NEW NFT");
        })
        it('shoudnt freeze if not owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            const newURI = 'newURI';
            const newSuffix = 'newSuffix';
            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            await expect(nft.connect(bob)["freeze(uint256)"](id)).to.be.revertedWithCustomError(nft, "TokenIsNotOwnedBySender()");
            await expect(nft.connect(bob)["freeze(uint256,string,string)"](id, newURI, newSuffix)).to.be.revertedWithCustomError(nft,"TokenIsNotOwnedBySender()");
            
        })
        
        it('check new tokenURI after freeze and revert back after unfreeze', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;
            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 

            const newURI = 'newURI';
            const newSuffix = 'newSuffix';
            expect(await nft.tokenURI(id)).to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));
            await nft.connect(alice)["freeze(uint256,string,string)"](id, newURI, newSuffix);

            expect(await nft.tokenURI(id)).not.to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));
            expect(await nft.tokenURI(id)).to.be.equal(newURI.concat(toHexString(id)).concat(newSuffix));

            await nft.connect(alice)["unfreeze(uint256)"](id);

            expect(await nft.tokenURI(id)).to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));
            expect(await nft.tokenURI(id)).not.to.be.equal(newURI.concat(toHexString(id)).concat(newSuffix));

        })
        it('check holding current tokenURI after freeze', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;
            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            const newURI = 'newURI';
            const newSuffix = 'newSuffix';
            expect(await nft.tokenURI(id)).to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));

            await nft.connect(alice)["freeze(uint256)"](id);

            await nft.setBaseURI(newURI);
            expect(await nft.baseURI()).to.be.equal(newURI);
            await nft.setSuffix(newSuffix);
            expect(await nft.suffix()).to.be.equal(newSuffix);

            expect(await nft.tokenURI(id)).to.be.equal(baseURI.concat(toHexString(id)).concat(suffix));
            expect(await nft.tokenURI(id)).not.to.be.equal(newURI.concat(toHexString(id)).concat(newSuffix));

        })

        it('should transfer token to user', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            const nftBalanceBeforeAlice = await nft.balanceOf(alice.address);
            const nftBalanceBeforeBob = await nft.balanceOf(bob.address);
            expect(nftBalanceBeforeAlice).to.be.equal(1n);
            expect(nftBalanceBeforeBob).to.be.equal(0n);
            await nft.connect(alice).transferFrom(alice.address, bob.address, id);
            const nftBalanceAfterAlice = await nft.balanceOf(alice.address);
            const nftBalanceAfterBob = await nft.balanceOf(bob.address);
            expect(nftBalanceAfterAlice).to.be.equal(0n);
            expect(nftBalanceAfterBob).to.be.equal(1n);
            expect(await nft.ownerOf(id)).to.be.equal(bob.address);

        })

        it('should transfer token to user via approve', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            const nftBalanceBeforeAlice = await nft.balanceOf(alice.address);
            const nftBalanceBeforeBob = await nft.balanceOf(bob.address);
            expect(nftBalanceBeforeAlice).to.be.equal(1n);
            expect(nftBalanceBeforeBob).to.be.equal(0n);
            await nft.connect(alice).approve(bob.address, id);
            await nft.connect(bob).transferFrom(alice.address, bob.address, id);
            const nftBalanceAfterAlice = await nft.balanceOf(alice.address);
            const nftBalanceAfterBob = await nft.balanceOf(bob.address);
            expect(nftBalanceAfterAlice).to.be.equal(0n);
            expect(nftBalanceAfterBob).to.be.equal(1n);
            expect(await nft.ownerOf(id)).to.be.equal(bob.address);

        })

        it('should transfer token to user via operator', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            const nftBalanceBeforeAlice = await nft.balanceOf(alice.address);
            const nftBalanceBeforeBob = await nft.balanceOf(bob.address);
            expect(nftBalanceBeforeAlice).to.be.equal(1n);
            expect(nftBalanceBeforeBob).to.be.equal(0n);
            await nft.connect(alice).setApprovalForAll(charlie.address, true);
            await nft.connect(charlie).transferFrom(alice.address, bob.address, id);
            const nftBalanceAfterAlice = await nft.balanceOf(alice.address);
            const nftBalanceAfterBob = await nft.balanceOf(bob.address);
            expect(nftBalanceAfterAlice).to.be.equal(0n);
            expect(nftBalanceAfterBob).to.be.equal(1n);
            expect(await nft.ownerOf(id)).to.be.equal(bob.address);

        })

        it('should correct burn token', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                id,
                ZERO_ADDRESS,
                DEAD_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            expect(await nft.balanceOf(DEAD_ADDRESS)).to.be.equal(0n);
            await nft.connect(alice).burn(id);
            expect(await nft.balanceOf(DEAD_ADDRESS)).to.be.equal(1n);
            expect(await nft.ownerOf(id)).to.be.equal(DEAD_ADDRESS);
        })

        it('shouldnt transfer token if not owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            await expect(nft.connect(bob).transferFrom(alice.address, bob.address, id)).to.be.revertedWithCustomError(nft, "CantManageThisToken()");
        })
        it('shouldnt transfer token on zero address', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, 0n, alice.address,{value: price}); 
            await expect(nft.connect(alice).transferFrom(alice.address, ZERO_ADDRESS, id)).to.be.revertedWithCustomError(nft, "CantTransferToTheZeroAddress()");
        })

        it('should correct get token of owner by index', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).buy([id + 10n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).buy([id + 100n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            const token1 = await nft.tokenOfOwnerByIndex(bob.address, 0n);
            const token2 = await nft.tokenOfOwnerByIndex(bob.address, 1n);
            const token3 = await nft.tokenOfOwnerByIndex(bob.address, 2n);
            expect(token1).to.be.equal(id);
            expect(token2).to.be.equal(id + 10n);
            expect(token3).to.be.equal(id + 100n);
        })
        it('should correct get totalSupply', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).buy([id + 10n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).buy([id + 100n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(alice).buy([id + 2n], ZERO_ADDRESS, price, false, 0n, alice.address, {value: price}); 
            await nft.connect(charlie).buy([id + 1000n], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price}); 
            const totalSupply = await nft.totalSupply();
            expect(totalSupply).to.be.equal(5n);
        })
        

        it('should correct get token by index', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft
            } = res;

            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(alice).buy([id + 1n], ZERO_ADDRESS, price, false, 0n, alice.address, {value: price}); 
            await nft.connect(charlie).buy([id + 2n], ZERO_ADDRESS, price, false, 0n, charlie.address, {value: price}); 
            const token1 = await nft.tokenByIndex(0n);
            const token2 = await nft.tokenByIndex(1n);
            const token3 = await nft.tokenByIndex(2n);
            expect(token1).to.be.equal(id);
            expect(token2).to.be.equal(id + 1n);
            expect(token3).to.be.equal(id + 2n);
        })


        it('shouldnt show tokenOfOwnerByIndex if owner index is out of bounds', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,
                nft
            } = res;

            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.tokenOfOwnerByIndex(bob.address, 2n)).to.be.revertedWith("ERC721Enumerable: owner index out of bounds");
        })

        it('shouldnt show tokenByIndex if index is out of bounds', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,
                nft
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.tokenByIndex(2n)).to.be.revertedWith("ERC721Enumerable: global index out of bounds");
        })

        it('shouldnt show balance of zero address', async() => {
            const res = await loadFixture(deployNFT);
            const {
                ZERO_ADDRESS,
                nft
            } = res;
            
            await expect(nft.balanceOf(ZERO_ADDRESS)).to.be.revertedWith("ERC721: balance query for the zero address");
        })

        it('shouldnt show owner of nonexisting token', async() => {
            const res = await loadFixture(deployNFT);
            const {
                nft
            } = res;
            
            await expect(nft.ownerOf(100n)).to.be.revertedWith("ERC721: owner query for nonexistent token");
        })

        it('shouldnt show tokenURI of nonexisting token', async() => {
            const res = await loadFixture(deployNFT);
            const {
                nft
            } = res;
            
            await expect(nft.tokenURI(100n)).to.be.revertedWith("ERC721URIStorage: URI query for nonexistent token");
        })
        it('should return tokenID if baseURI is empty', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                saleParams,
                commissions,
                price,
                suffix,
                seriesId,

                nft
            } = res;
            
            const newSeriesParams = [
                alice.address,  
                10000n,
                saleParams,
                commissions,
                "",
                suffix
            ];
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, newSeriesParams);
            expect(await nft.tokenURI(id)).to.be.equal(toHexString(id).concat(suffix));
        })

        it('shouldnt approve to current owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,

                nft
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(bob).approve(bob.address, id)).to.be.revertedWith("ERC721: approval to current owner");
        })
        it('shouldnt approve if not owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,

                nft
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(alice).approve(charlie.address, id)).to.be.revertedWith("ERC721: approve caller is not owner nor approved for all");
        })
        it('shouldnt approve for all if operator is the owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,

                nft
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(bob).setApprovalForAll(bob.address, true)).to.be.revertedWith("ERC721: approve to caller");
        })

        it('should correct safeTransfer to contract without data', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,
                nft,
                buyer
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob)["safeTransferFrom(address,address,uint256)"](bob.address, buyer.target, id);
            expect(await nft.ownerOf(id)).to.be.equal(buyer.target);
            expect(await nft.balanceOf(buyer.target)).to.be.equal(1n);
        })

        it('shouldnt safeTransfer if not owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft,
                buyer
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(alice)["safeTransferFrom(address,address,uint256)"](bob.address, buyer.target, id)).to.be.revertedWithCustomError(nft, "CantManageThisToken()");
        })
    
        it('shouldnt burn if not owner', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                price,
                nft,
                buyer
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(alice).burn(id)).to.be.revertedWithCustomError(nft, "CantManageThisToken()");
        })

        it('should burn if approved before', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                id,
                ZERO_ADDRESS,
                DEAD_ADDRESS,
                price,
                nft,
                buyer
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).approve(alice.address, id);
            expect(await nft.balanceOf(DEAD_ADDRESS)).to.be.equal(0n);
            await nft.connect(alice).burn(id);
            expect(await nft.balanceOf(DEAD_ADDRESS)).to.be.equal(1n);
            expect(await nft.ownerOf(id)).to.be.equal(DEAD_ADDRESS);
        })

        it('should correct safeTransfer to contract with data', async() => {
            const res = await loadFixture(deployNFT);
            const {
                bob,
                id,
                ZERO_ADDRESS,
                price,
                nft,
                buyer
            } = res;
            
            const data = "0x123456";
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob)["safeTransferFrom(address,address,uint256,bytes)"](bob.address, buyer.target, id, data);
            expect(await nft.ownerOf(id)).to.be.equal(buyer.target);
            expect(await nft.balanceOf(buyer.target)).to.be.equal(1n);
        })

        it('shouldnt safeTransfer to non-ERC721receiver', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft,
                erc20
            } = res;
            
            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await expect(nft.connect(bob)["safeTransferFrom(address,address,uint256)"](bob.address, erc20.target, id)).to.be.revertedWith("ERC721: transfer to non ERC721Receiver implementer");
        })

        it('should correct get token\'s list via allTokens()', async() => {
            const res = await loadFixture(deployNFT);
            const {
                alice,
                bob,
                charlie,
                id,
                ZERO_ADDRESS,
                price,
                baseURI,
                suffix,

                nft,
                erc20
            } = res;

            var list;

            // there are no tokens yet
            await expect(
                nft.allTokens(0,0)
            ).to.be.revertedWith('ERC721Enumerable: global index out of bounds');

            await nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 

            //##### single token in a list #######
            // try to get 0 of 1 tokens from 0 pos
            list = await nft.allTokens(0,0);
            expect(list.length).to.be.eq(0);
            
            // try to get 1 of 1 tokens from 0 pos
            list = await nft.allTokens(0,1);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id);

            // try to get 2 of 1 tokens from 0 pos
            list = await nft.allTokens(0,2);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id);

            // try to get 100 of 1 tokens from 0 pos
            list = await nft.allTokens(0,100);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id);

            // try to get 1 of 1 tokens from 1 pos
            await expect(nft.allTokens(1,0)).to.be.revertedWith('ERC721Enumerable: global index out of bounds');
            // try to get 1 of 1 tokens from 22 pos
            await expect(nft.allTokens(22,0)).to.be.revertedWith('ERC721Enumerable: global index out of bounds');

            // add another 2n
            await nft.connect(bob).buy([id + 10n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 
            await nft.connect(bob).buy([id + 100n], ZERO_ADDRESS, price, false, 0n, bob.address, {value: price}); 

            // try to get 0 of 3 tokens from 0 pos
            list = await nft.allTokens(0,0);
            expect(list.length).to.be.eq(0);

            // try to get 1 of 3 tokens from 0 pos
            list = await nft.allTokens(0,1);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id);

            // try to get 3 of 3 tokens from 0 pos
            list = await nft.allTokens(0,3);

            expect(list.length).to.be.eq(3);
            expect(list[0]).to.be.eq(id);
            expect(list[1]).to.be.eq(id + 10n);
            expect(list[2]).to.be.eq(id + 100n);

            // try to get 1 of 3 tokens from 2 pos
            list = await nft.allTokens(2,1);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id + 100n);

            // try to get 100 of 1 tokens from 2 pos
            list = await nft.allTokens(2,100);
            expect(list.length).to.be.eq(1);
            expect(list[0]).to.be.eq(id + 100n);

            // try to get 1 of 1 tokens from 22 pos
            await expect(nft.allTokens(22,0)).to.be.revertedWith('ERC721Enumerable: global index out of bounds');
        })
            
    })

});
