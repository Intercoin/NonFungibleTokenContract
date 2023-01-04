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
    describe("Standart ERC721 functional tests", function () {
        const accounts = waffle.provider.getWallets();
        const owner = accounts[0];                     
        const alice = accounts[1];
        const bob = accounts[2];
        const charlie = accounts[3];

        const seriesId = BigNumber.from('1000');
        const tokenId = ONE;
        const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
        const price = ethers.utils.parseEther('1');
        const autoincrementPrice = ZERO;
        const now = Math.round(Date.now() / 1000);   
        const baseURI = "http://baseUri/";
        const suffix = ".json";
        const limit = BigNumber.from('10000');
        const saleParams = [
            now + 100000, 
            ZERO_ADDRESS, 
            price,
            autoincrementPrice
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

        beforeEach("deploying", async() => {
            const ERC20Factory = await ethers.getContractFactory("MockERC20");

            const NFTMainFactory = await ethers.getContractFactory("NFTMain");
            const NFTStateFactory = await ethers.getContractFactory("NFTState");
            const NFTViewFactory = await ethers.getContractFactory("NFTView");

            const BuyerFactory = await ethers.getContractFactory("Buyer");
            
            this.nftState = await NFTStateFactory.deploy();
            this.nftView = await NFTViewFactory.deploy();

            this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
            this.nft = await NFTMainFactory.deploy();
            await this.nft.connect(owner).initialize(this.nftState.address, this.nftView.address, "NFT Edition", "NFT", "", "", "", ZERO_ADDRESS, ZERO_ADDRESS);
            await this.nft.connect(owner)["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, seriesParams);
            const retval = '0x150b7a02';
            const error = ZERO;
            this.buyer = await BuyerFactory.deploy(retval, error);


            await this.erc20.mint(owner.address, TOTALSUPPLY);

        })

        describe('transfer tests', async() => {
            it('check name, symbol and tokenURI', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address, {value: price}); 
                //console.log("await this.nft.tokenURI(id) = ", await this.nft.tokenURI(id));
                expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));
                expect(await this.nft.name()).to.be.equal("NFT Edition");
                expect(await this.nft.symbol()).to.be.equal("NFT");
            })
            it('check name and symbol after owner set', async() => {
                await expect(this.nft.connect(alice).setNameAndSymbol("NEW NFT Edition", "NEW NFT")).to.be.revertedWith("Ownable: caller is not the owner");
                await this.nft.connect(owner).setNameAndSymbol("NEW NFT Edition", "NEW NFT"); 
                expect(await this.nft.name()).to.be.equal("NEW NFT Edition");
                expect(await this.nft.symbol()).to.be.equal("NEW NFT");
            })
            it('shoudnt freeze if not owner', async() => {
                const newURI = 'newURI';
                const newSuffix = 'newSuffix';
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                await expect(this.nft.connect(bob)["freeze(uint256)"](id)).to.be.revertedWith("token isn't owned by sender");
                await expect(this.nft.connect(bob)["freeze(uint256,string,string)"](id, newURI, newSuffix)).to.be.revertedWith("token isn't owned by sender");
                
            })
            it('check new tokenURI after freeze and revert back after unfreeze', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 

                const newURI = 'newURI';
                const newSuffix = 'newSuffix';
                expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));
                await this.nft.connect(alice)["freeze(uint256,string,string)"](id, newURI, newSuffix);

                expect(await this.nft.tokenURI(id)).not.to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));
                expect(await this.nft.tokenURI(id)).to.be.equal(newURI.concat(id.toHexString().substring(2)).concat(newSuffix));

                await this.nft.connect(alice)["unfreeze(uint256)"](id);

                expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));
                expect(await this.nft.tokenURI(id)).not.to.be.equal(newURI.concat(id.toHexString().substring(2)).concat(newSuffix));

            })
            it('check holding current tokenURI after freeze', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                const newURI = 'newURI';
                const newSuffix = 'newSuffix';
                expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));

                await this.nft.connect(alice)["freeze(uint256)"](id);

                await this.nft.setBaseURI(newURI);
                expect(await this.nft.baseURI()).to.be.equal(newURI);
                await this.nft.setSuffix(newSuffix);
                expect(await this.nft.suffix()).to.be.equal(newSuffix);

                expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toHexString().substring(2)).concat(suffix));
                expect(await this.nft.tokenURI(id)).not.to.be.equal(newURI.concat(id.toHexString().substring(2)).concat(newSuffix));

            })

            it('should transfer token to user', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                const nftBalanceBeforeAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceBeforeBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceBeforeAlice).to.be.equal(ONE);
                expect(nftBalanceBeforeBob).to.be.equal(ZERO);
                await this.nft.connect(alice).transferFrom(alice.address, bob.address, id);
                const nftBalanceAfterAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceAfterBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceAfterAlice).to.be.equal(ZERO);
                expect(nftBalanceAfterBob).to.be.equal(ONE);
                expect(await this.nft.ownerOf(id)).to.be.equal(bob.address);

            })

            it('should transfer token to user via approve', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                const nftBalanceBeforeAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceBeforeBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceBeforeAlice).to.be.equal(ONE);
                expect(nftBalanceBeforeBob).to.be.equal(ZERO);
                await this.nft.connect(alice).approve(bob.address, id);
                await this.nft.connect(bob).transferFrom(alice.address, bob.address, id);
                const nftBalanceAfterAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceAfterBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceAfterAlice).to.be.equal(ZERO);
                expect(nftBalanceAfterBob).to.be.equal(ONE);
                expect(await this.nft.ownerOf(id)).to.be.equal(bob.address);

            })

            it('should transfer token to user via operator', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                const nftBalanceBeforeAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceBeforeBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceBeforeAlice).to.be.equal(ONE);
                expect(nftBalanceBeforeBob).to.be.equal(ZERO);
                await this.nft.connect(alice).setApprovalForAll(charlie.address, true);
                await this.nft.connect(charlie).transferFrom(alice.address, bob.address, id);
                const nftBalanceAfterAlice = await this.nft.balanceOf(alice.address);
                const nftBalanceAfterBob = await this.nft.balanceOf(bob.address);
                expect(nftBalanceAfterAlice).to.be.equal(ZERO);
                expect(nftBalanceAfterBob).to.be.equal(ONE);
                expect(await this.nft.ownerOf(id)).to.be.equal(bob.address);

            })

            it('should correct burn token', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ZERO);
                await this.nft.connect(alice).burn(id);
                expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ONE);
                expect(await this.nft.ownerOf(id)).to.be.equal(DEAD_ADDRESS);
            })

            it('shouldnt transfer token if not owner', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                await expect(this.nft.connect(bob).transferFrom(alice.address, bob.address, id)).to.be.revertedWith("you can't manage this token");
            })
            it('shouldnt transfer token on zero address', async() => {
                await this.nft.connect(alice).buy([id], ZERO_ADDRESS, price, false, ZERO, alice.address,{value: price}); 
                await expect(this.nft.connect(alice).transferFrom(alice.address, ZERO_ADDRESS, id)).to.be.revertedWith("can't transfer to the zero address");
            })

            it('should correct get token of owner by index', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob).buy([id.add(TEN)], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob).buy([id.add(HUN)], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                const token1 = await this.nft.tokenOfOwnerByIndex(bob.address, ZERO);
                const token2 = await this.nft.tokenOfOwnerByIndex(bob.address, ONE);
                const token3 = await this.nft.tokenOfOwnerByIndex(bob.address, TWO);
                expect(token1).to.be.equal(id);
                expect(token2).to.be.equal(id.add(TEN));
                expect(token3).to.be.equal(id.add(HUN));
            })
            it('should correct get totalSupply', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob).buy([id.add(TEN)], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob).buy([id.add(HUN)], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(alice).buy([id.add(TWO)], ZERO_ADDRESS, price, false, ZERO, alice.address, {value: price}); 
                await this.nft.connect(charlie).buy([id.add(HUN.add(TEN))], ZERO_ADDRESS, price, false, ZERO, charlie.address, {value: price}); 
                const totalSupply = await this.nft.totalSupply();
                expect(totalSupply).to.be.equal(FIVE);
            })
            it('should correct get token by index', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(alice).buy([id.add(ONE)], ZERO_ADDRESS, price, false, ZERO, alice.address, {value: price}); 
                await this.nft.connect(charlie).buy([id.add(TWO)], ZERO_ADDRESS, price, false, ZERO, charlie.address, {value: price}); 
                const token1 = await this.nft.tokenByIndex(ZERO);
                const token2 = await this.nft.tokenByIndex(ONE);
                const token3 = await this.nft.tokenByIndex(TWO);
                expect(token1).to.be.equal(id);
                expect(token2).to.be.equal(id.add(ONE));
                expect(token3).to.be.equal(id.add(TWO));
            })

            it('shouldnt show tokenOfOwnerByIndex if owner index is out of bounds', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.tokenOfOwnerByIndex(bob.address, TWO)).to.be.revertedWith("ERC721Enumerable: owner index out of bounds");
            })

            it('shouldnt show tokenByIndex if index is out of bounds', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.tokenByIndex(TWO)).to.be.revertedWith("ERC721Enumerable: global index out of bounds");
            })

            it('shouldnt show balance of zero address', async() => {
                await expect(this.nft.balanceOf(ZERO_ADDRESS)).to.be.revertedWith("ERC721: balance query for the zero address");
            })

            it('shouldnt show owner of nonexisting token', async() => {
                await expect(this.nft.ownerOf(HUN)).to.be.revertedWith("ERC721: owner query for nonexistent token");
            })

            it('shouldnt show tokenURI of nonexisting token', async() => {
                await expect(this.nft.tokenURI(HUN)).to.be.revertedWith("ERC721URIStorage: URI query for nonexistent token");
            })
            it('should return tokenID if baseURI is empty', async() => {
                const newSeriesParams = [
                    alice.address,  
                    10000,
                    saleParams,
                    commissions,
                    "",
                    suffix
                ];
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft["setSeriesInfo(uint64,(address,uint32,(uint64,address,uint256,uint256),(uint64,address),string,string))"](seriesId, newSeriesParams);
                expect(await this.nft.tokenURI(id)).to.be.equal(id.toHexString().substring(2).concat(suffix));
            })
            it('shouldnt approve to current owner', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(bob).approve(bob.address, id)).to.be.revertedWith("ERC721: approval to current owner");
            })
            it('shouldnt approve if not owner', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(alice).approve(charlie.address, id)).to.be.revertedWith("ERC721: approve caller is not owner nor approved for all");
            })
            it('shouldnt approve for all if operator is the owner', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(bob).setApprovalForAll(bob.address, true)).to.be.revertedWith("ERC721: approve to caller");
            })

            it('should correct safeTransfer to contract without data', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob)["safeTransferFrom(address,address,uint256)"](bob.address, this.buyer.address, id);
                expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
                expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
            })

            it('shouldnt safeTransfer if not owner', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(alice)["safeTransferFrom(address,address,uint256)"](bob.address, this.buyer.address, id)).to.be.revertedWith("you can't manage this token");
            })

            it('shouldnt burn if not owner', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(alice).burn(id)).to.be.revertedWith("you can't manage this token");
            })

            it('should burn if approved before', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob).approve(alice.address, id);
                expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ZERO);
                await this.nft.connect(alice).burn(id);
                expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ONE);
                expect(await this.nft.ownerOf(id)).to.be.equal(DEAD_ADDRESS);
            })

            it('should correct safeTransfer to contract with data', async() => {
                const data = "0x123456";
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await this.nft.connect(bob)["safeTransferFrom(address,address,uint256,bytes)"](bob.address, this.buyer.address, id, data);
                expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
                expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
            })

            it('shouldnt safeTransfer to non-ERC721receiver', async() => {
                await this.nft.connect(bob).buy([id], ZERO_ADDRESS, price, false, ZERO, bob.address, {value: price}); 
                await expect(this.nft.connect(bob)["safeTransferFrom(address,address,uint256)"](bob.address, this.erc20.address, id)).to.be.revertedWith("ERC721: transfer to non ERC721Receiver implementer");
            })

            
        })
    
    


    });
});
