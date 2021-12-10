const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';



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



describe("ERC721UpgradeableExt test", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "someURI";
    const limit = BigNumber.from('10000');
    const saleParams = [
        ZERO_ADDRESS, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];

    beforeEach("deploying", async() => {
        const ERC20Factory = await ethers.getContractFactory("MockERC20");
        const NFTFactory = await ethers.getContractFactory("NFT");
        this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
        this.nft = await NFTFactory.deploy();
        await this.nft.connect(owner).initialize("NFT Edition", "NFT");
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);

        await this.erc20.mint(owner.address, TOTALSUPPLY);

    })

    describe('transfer tests', async() => {
        it('check name, symbol and tokenURI', async() => {
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
            expect(await this.nft.tokenURI(id)).to.be.equal(baseURI.concat(id.toString()));
            expect(await this.nft.name()).to.be.equal("NFT Edition");
            expect(await this.nft.symbol()).to.be.equal("NFT");
        })
        it('should transfer token to user', async() => {
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
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
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
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
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
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
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
            expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ZERO);
            await this.nft.connect(alice).burn(id);
            expect(await this.nft.balanceOf(DEAD_ADDRESS)).to.be.equal(ONE);
            expect(await this.nft.ownerOf(id)).to.be.equal(DEAD_ADDRESS);
        })

        it('shouldnt transfer token if not owner', async() => {
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
            await expect(this.nft.connect(bob).transferFrom(alice.address, bob.address, id)).to.be.revertedWith("ERC721: transfer caller is not owner nor approved");
        })
        it('shouldnt transfer token on zero address', async() => {
            await this.nft.connect(alice)["buy(uint256)"](id, {value: price}); 
            await expect(this.nft.connect(alice).transferFrom(alice.address, ZERO_ADDRESS, id)).to.be.revertedWith("ERC721: transfer to the zero address");
        })

        it('should correct get token of owner by index', async() => {
            await this.nft.connect(bob)["buy(uint256)"](id, {value: price}); 
            await this.nft.connect(bob)["buy(uint256)"](id.add(TEN), {value: price}); 
            await this.nft.connect(bob)["buy(uint256)"](id.add(HUN), {value: price}); 
            const token1 = await this.nft.tokenOfOwnerByIndex(bob.address, ZERO);
            const token2 = await this.nft.tokenOfOwnerByIndex(bob.address, ONE);
            const token3 = await this.nft.tokenOfOwnerByIndex(bob.address, TWO);
            expect(token1).to.be.equal(id);
            expect(token2).to.be.equal(id.add(TEN));
            expect(token3).to.be.equal(id.add(HUN));
        })
        it('should correct get totalSupply', async() => {
            await this.nft.connect(bob)["buy(uint256)"](id, {value: price}); 
            await this.nft.connect(bob)["buy(uint256)"](id.add(TEN), {value: price}); 
            await this.nft.connect(bob)["buy(uint256)"](id.add(HUN), {value: price}); 
            await this.nft.connect(alice)["buy(uint256)"](id.add(TWO), {value: price}); 
            await this.nft.connect(charlie)["buy(uint256)"](id.add(HUN.add(TEN)), {value: price}); 
            const totalSupply = await this.nft.totalSupply();
            expect(totalSupply).to.be.equal(FIVE);
        })
        it('should correct get tokan by index', async() => {
            await this.nft.connect(bob)["buy(uint256)"](id, {value: price}); 
            await this.nft.connect(alice)["buy(uint256)"](id.add(ONE), {value: price}); 
            await this.nft.connect(charlie)["buy(uint256)"](id.add(TWO), {value: price}); 
            const token1 = await this.nft.tokenByIndex(ZERO);
            const token2 = await this.nft.tokenByIndex(ONE);
            const token3 = await this.nft.tokenByIndex(TWO);
            expect(token1).to.be.equal(id);
            expect(token2).to.be.equal(id.add(ONE));
            expect(token3).to.be.equal(id.add(TWO));
        })
    })

  
  


});
