const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');          

const ONE = BigNumber.from('1');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

chai.use(require('chai-bignumber')());


describe("ERC20Example test", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    beforeEach("deploying", async() => {
        const ERC20Factory = await ethers.getContractFactory("ERC20Example");
        this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");

        await this.erc20.mint(owner.address, TOTALSUPPLY);

        await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
    })


  it("should correct transfer tokens", async() => {
    
    const aliceBalanceBefore = await this.erc20.balanceOf(alice.address);
    const bobBalanceBefore = await this.erc20.balanceOf(bob.address);

    const aliceAmount = ethers.utils.parseEther('10');
    await this.erc20.connect(alice).transfer(bob.address, aliceAmount);

    const aliceBalanceAfter = await this.erc20.balanceOf(alice.address);
    const bobBalanceAfter = await this.erc20.balanceOf(bob.address);

    expect(bobBalanceAfter).to.be.equal(
        bobBalanceBefore.add(
            aliceBalanceBefore.sub(aliceBalanceAfter)
        )
    );

    console.log("Alice's balance is:", ethers.utils.formatEther(aliceBalanceAfter));
    console.log("Bob's balance is:", ethers.utils.formatEther(bobBalanceAfter));
    
  });
});

// UNIT TESTS:
// balanceOf()
// ownerOf()
// setTokenInfo()
// setSeriesInfo()
// listOnSale

// USER CASES:
// Alice creates collection

