const { ethers, waffle } = require('hardhat');
const { BigNumber } = require('ethers');
const { expect } = require('chai');
const chai = require('chai');
const { time } = require('@openzeppelin/test-helpers');

const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
const DEAD_ADDRESS = '0x000000000000000000000000000000000000dEaD';


const ZERO = BigNumber.from('0');
const ONE = BigNumber.from('1');
const TWO = BigNumber.from('2');
const THREE = BigNumber.from('3');
const TEN = BigNumber.from('10');
const HUN = BigNumber.from('100');

const SERIES_BITS = 192;

chai.use(require('chai-bignumber')());



describe("NFT test", function () {
    const accounts = waffle.provider.getWallets();
    const owner = accounts[0];                     
    const alice = accounts[1];
    const bob = accounts[2];
    const charlie = accounts[3];

    beforeEach("deploying", async() => {
        const ERC20Factory = await ethers.getContractFactory("MockERC20");
        const NFTFactory = await ethers.getContractFactory("NFTSafeHook");
        const HookFactory = await ethers.getContractFactory("MockHook");
        const BuyerFactory = await ethers.getContractFactory("Buyer");
        this.erc20 = await ERC20Factory.deploy("ERC20 Token", "ERC20");
        this.hook1 = await HookFactory.deploy();
        this.hook2 = await HookFactory.deploy();
        this.hook3 = await HookFactory.deploy();
        const retval = '0x150b7a02';
        const error = ZERO;
        this.buyer = await BuyerFactory.deploy(retval, error);
        this.nft = await NFTFactory.deploy();
        await this.nft.connect(owner).initialize("NFT Edition", "NFT");

        await this.erc20.mint(owner.address, TOTALSUPPLY);

        await this.erc20.transfer(alice.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(bob.address, ethers.utils.parseEther('100'));
        await this.erc20.transfer(charlie.address, ethers.utils.parseEther('100'));
    })

  it("should correct put series on sale for Alice", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "someURI";
    const saleParams = [
      ZERO_ADDRESS, 
      price, 
      now + 100000, 
    ]
    const params = [
      alice.address, 
      saleParams,
      10000,
      baseURI
    ];
    await this.nft.connect(owner).setSeriesInfo(seriesId, params);
    const seriesInfo = await this.nft.getSeriesInfo(seriesId);
    expect(seriesInfo.author).to.be.equal(alice.address);
    expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
    expect(seriesInfo.saleInfo.price).to.be.equal(price);
    expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
    expect(seriesInfo.baseURI).to.be.equal(baseURI);
    expect(seriesInfo.limit).to.be.equal(10000);

  })

  // it("should correct put token on sale", async() => {
  //   const seriesId = BigNumber.from('1000');
  //   const tokenId = ONE;
  //   const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
  //   const price = ethers.utils.parseEther('1');
  //   const now = Math.round(Date.now() / 1000);   
  //   const baseURI = "someURI";
    
  //   const tokenParams = [
  //     alice.address, 
  //     ZERO_ADDRESS, 
  //     price, 
  //     now + 100000,
  //   ];
  //   const seriesParams = tokenParams.concat([baseURI, 10000]);

  //   await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);

  //   await this.nft.connect(alice).listForSale(id, price, ZERO_ADDRESS, 100000);
  //   const tokenInfo = await this.nft.getSaleInfo(id);
  //   expect(tokenInfo.owner).to.be.equal(alice.address);
  //   expect(tokenInfo.currency).to.be.equal(ZERO_ADDRESS);
  //   expect(tokenInfo.amount).to.be.equal(price);
  //   expect(tokenInfo.onSaleUntil).to.be.equal(now + 100000);


  // })

  describe("buy tests", async() => {
    const seriesId = BigNumber.from('1000');
    const tokenId = ONE;
    const id = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(tokenId);
    const price = ethers.utils.parseEther('1');
    const now = Math.round(Date.now() / 1000);   
    const baseURI = "";
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
    beforeEach("listing series on sale", async() => {
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
    })
    it("should correct mint NFT with ETH if ID doesn't exist", async() => {
      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeAlice = await ethers.provider.getBalance(alice.address);
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price.mul(TWO)}); // accidentially send more than needed
      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterAlice = await ethers.provider.getBalance(alice.address);
      expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.gt(price);
      expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);

      const saleInfo = await this.nft.getSaleInfo(id);
      expect(saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(saleInfo.price).to.be.equal(ZERO);
      expect(saleInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

  
    });

  
    it("should correct mint NFT with token if ID doesn't exist", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address, 
        saleParams, 
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(bob).approve(this.nft.address, price);
      const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
      const balanceBeforeAlice = await this.erc20.balanceOf(alice.address);
      await this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(TWO), false, ZERO); // accidentially send more than needed
      const balanceAfterBob = await this.erc20.balanceOf(bob.address);
      const balanceAfterAlice = await this.erc20.balanceOf(alice.address);
      expect(balanceBeforeBob.sub(balanceAfterBob)).to.be.equal(price);
      expect(balanceAfterAlice.sub(balanceBeforeAlice)).to.be.equal(price);
      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(bob.address);
      
      const saleInfo = await this.nft.getSaleInfo(id);
      expect(saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(saleInfo.price).to.be.equal(ZERO);
      expect(saleInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(this.erc20.address);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);


    });

    it("should correct buy minted NFT for ETH", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const saleParams = [
        ZERO_ADDRESS, 
        price.mul(TWO), 
        now + 100000,
      ];      

      await this.nft.connect(bob).setSaleInfo(id, saleParams);

      const balanceBeforeBob = await ethers.provider.getBalance(bob.address);
      const balanceBeforeCharlie = await ethers.provider.getBalance(charlie.address);
      await this.nft.connect(charlie)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price.mul(THREE)}); // accidentially send more than needed
      const balanceAfterBob = await ethers.provider.getBalance(bob.address);
      const balanceAfterCharlie = await ethers.provider.getBalance(charlie.address);
      expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
      expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.gt(price.mul(TWO));

      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(charlie.address);

      const saleInfo = await this.nft.getSaleInfo(id);
      expect(saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(saleInfo.price).to.be.equal(price.mul(TWO));
      expect(saleInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

    });

    it("should correct buy minted NFT for token", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const saleParams = [
        this.erc20.address, 
        price.mul(TWO), 
        now + 100000,
      ];      

      await this.nft.connect(bob).setSaleInfo(id, saleParams);

      const balanceBeforeBob = await this.erc20.balanceOf(bob.address);
      const balanceBeforeCharlie = await this.erc20.balanceOf(charlie.address);
      await this.erc20.connect(charlie).approve(this.nft.address, price.mul(THREE));
      await this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.mul(THREE), false, ZERO); // accidentially send more than needed
      const balanceAfterBob = await this.erc20.balanceOf(bob.address);
      const balanceAfterCharlie = await this.erc20.balanceOf(charlie.address);
      expect(balanceAfterBob.sub(balanceBeforeBob)).to.be.equal(price.mul(TWO));
      expect(balanceBeforeCharlie.sub(balanceAfterCharlie)).to.be.equal(price.mul(TWO));

      const newOwner = await this.nft.ownerOf(id);
      expect(newOwner).to.be.equal(charlie.address);

      const saleInfo = await this.nft.getSaleInfo(id);
      expect(saleInfo.currency).to.be.equal(this.erc20.address);
      expect(saleInfo.price).to.be.equal(price.mul(TWO));
      expect(saleInfo.onSaleUntil).to.be.equal(ZERO);

      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(10000);

    });

    it("should correct mint NFT from own series", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(alice).approve(this.nft.address, price);
      await this.nft.connect(alice)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO); 
    })

    it("shouldnt buy if token was burned (ETH)", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await this.nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
      await expect(this.nft.connect(charlie)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price})).to.be.revertedWith("token is not on sale");
    })

    it("shouldnt buy if token was burned (token)", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await this.nft.connect(bob).transferFrom(bob.address, DEAD_ADDRESS, id);
      await this.erc20.connect(charlie).approve(this.nft.address, price);
      await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO)).to.be.revertedWith("token is not on sale");
    })

    it("shouldnt buy if token wasnt listed on sale", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await expect(this.nft.connect(charlie)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price})).to.be.revertedWith('token is not on sale');
    })

    it("shouldnt mint if series was unlisted from sale", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        ZERO, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await expect(this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price})).to.be.revertedWith("token is not on sale");
    })
    
    it("shouldnt buy if user passed unsufficient ETH", async() => {
      await expect(this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price.sub(ONE)})).to.be.revertedWith("insufficient ETH");
    })

    it("shouldnt set token info if not owner", async() => {   
      const saleParams = [
        ZERO_ADDRESS, 
        price.mul(TWO), 
        now + 100000,
      ];   
      await expect(this.nft.connect(charlie).setSaleInfo(id, saleParams)).to.be.revertedWith("can call only by owner");
    })

    it("shouldnt buy if user approved unsufficient token amount", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];

      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(charlie).approve(this.nft.address, price.sub(ONE));
      await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ZERO)).to.be.revertedWith("insufficient amount");
    })

    it("shouldnt buy if user passed unsufficient token amount", async() => {

      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(charlie).approve(this.nft.address, price);
      await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price.sub(ONE), false, ZERO)).to.be.revertedWith("insufficient amount");
    })

    it("shouldnt buy if token is invalid", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await this.erc20.connect(charlie).approve(this.nft.address, price);
      const wrongAddress = bob.address;
      await expect(this.nft.connect(charlie)["buy(uint256,address,uint256,bool,uint256)"](id, wrongAddress, price, false, ZERO)).to.be.revertedWith("wrong currency for sale");
    })

    it("should correct list on sale via listForSale", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const duration = 1000;
      const newPrice = price.mul(TWO);
      const newCurrency = this.erc20.address;
      await this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);
      const saleInfo = await this.nft.getSaleInfo(id);
      expect(saleInfo.currency).to.be.equal(newCurrency);
      expect(saleInfo.price).to.be.equal(newPrice);
      const lastTs = await time.latest();
      expect(saleInfo.onSaleUntil).to.be.equal(+lastTs.toString() + duration);

    })

    it("shouldnt list on sale via listForSale if already listed", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const duration = 1000;
      const newPrice = price.mul(TWO);
      const newCurrency = this.erc20.address;
      await this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration);
      await expect(this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith('already in sale');

    })

    it("shouldnt list on sale via listForSale if not owner", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const duration = 1000;
      const newPrice = price.mul(TWO);
      const newCurrency = this.erc20.address;
      await expect(this.nft.connect(alice).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith('invalid token owner');

    })

    it("shouldnt list on sale via listForSale if duration is invalid", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      const duration = 0;
      const newPrice = price.mul(TWO);
      const newCurrency = this.erc20.address;
      await expect(this.nft.connect(bob).listForSale(id, newPrice, newCurrency, duration)).to.be.revertedWith('invalid duration');

    })

    it("shouldnt buy burnt token", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await this.nft.connect(bob).burn(id);
      await expect(this.nft.connect(charlie)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price})).to.be.revertedWith('token is not on sale');
    })

    it("should mint tokens for several users via mintAndDistribute", async() => {
      const series1Id = BigNumber.from('1000');
      const series2Id = BigNumber.from('1005');
      const tokenId1 = ONE;
      const tokenId2 = TEN;
      const tokenId3 = HUN;
      const id1 = series1Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId1);
      const id2 = series2Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId2);
      const id3 = series2Id.mul(TWO.pow(BigNumber.from('192'))).add(tokenId3);
  
      const ids = [id1, id2, id3];
      const users = [
        alice.address,
        bob.address,
        charlie.address
      ]
      await this.nft.connect(owner).mintAndDistribute(ids, users);
      expect(await this.nft.balanceOf(alice.address)).to.be.equal(ONE);
      expect(await this.nft.balanceOf(bob.address)).to.be.equal(ONE);
      expect(await this.nft.balanceOf(charlie.address)).to.be.equal(ONE);

      expect(await this.nft.ownerOf(id1)).to.be.equal(alice.address);
      expect(await this.nft.ownerOf(id2)).to.be.equal(bob.address);
      expect(await this.nft.ownerOf(id3)).to.be.equal(charlie.address);
             
    })

    it("shouldnt mint tokens via mintAndDistribute if lengths are not the same ", async() => {
      const ids = [1, 2, 3];
      const wrongLengthAddresses = [
        alice.address,
        bob.address
      ]

      await expect(this.nft.connect(owner).mintAndDistribute(ids, wrongLengthAddresses)).to.be.revertedWith('lengths should be the same');

    })

    it("should correct call setSaleInfo as an owner of series", async() => {
      const newLimit = 11000;
      const saleParams = [
        ZERO_ADDRESS, 
        price, 
        now + 100000, 
      ]
      const newParams = [
        alice.address,  
        saleParams,
        newLimit,
        baseURI
      ];
      await this.nft.connect(alice).setSeriesInfo(seriesId, newParams);
      const seriesInfo = await this.nft.getSeriesInfo(seriesId);
      expect(seriesInfo.author).to.be.equal(alice.address);
      expect(seriesInfo.saleInfo.currency).to.be.equal(ZERO_ADDRESS);
      expect(seriesInfo.saleInfo.price).to.be.equal(price);
      expect(seriesInfo.saleInfo.onSaleUntil).to.be.equal(now + 100000);
      expect(seriesInfo.baseURI).to.be.equal(baseURI);
      expect(seriesInfo.limit).to.be.equal(newLimit);
  
    })

    it("shouldnt call setSaleInfo as an owner of series", async() => {
      await expect(this.nft.connect(bob).setSeriesInfo(seriesId, seriesParams)).to.be.revertedWith('!onlyContractOrSeriesOwner');

    })

    it("shouldnt let buy for ETH if token currency specified", async() => {
      const saleParams = [
        this.erc20.address, 
        price, 
        now + 100000, 
      ]
      const seriesParams = [
        alice.address,  
        saleParams,
        10000,
        baseURI
      ];
      await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);
      await expect(this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price})).to.be.revertedWith('wrong currency for sale');

    })

    it("shouldn correct list all tokens of user", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id.add(ONE), false, ZERO, {value: price});
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id.add(TWO), false, ZERO, {value: price});
      const bobTokens = await this.nft.connect(bob)["tokensByOwner(address)"](bob.address);
      expect(bobTokens[0]).to.be.equal(id);
      expect(bobTokens[1]).to.be.equal(id.add(ONE));
      expect(bobTokens[2]).to.be.equal(id.add(TWO));

    })

    it("should correct list tokens of user with output limit", async() => {
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id.add(ONE), false, ZERO, {value: price});
      await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id.add(TWO), false, ZERO, {value: price});
      const limit = ONE;
      const bobTokens = await this.nft.connect(bob)["tokensByOwner(address,uint256)"](bob.address,limit);
      expect(bobTokens[0]).to.be.equal(id);
      expect(bobTokens.length).to.be.equal(limit);

    })
    
    describe("hooks tests", async() => {
      it("should correct set hook (ETH test)", async() => {
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ONE, {value: price});
        expect(await this.nft.hooksCountByToken(id)).to.be.equal(ONE);
        const hooks = await this.nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(this.hook1.address);
        expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
      })

      it("shouldn't buy if hook number changed (ETH test)", async() => {
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
        await expect(this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ONE, {value: price})).to.be.revertedWith("wrong hookNumber");
      })

      it("should correct set hook (token test)", async() => {
        const saleParams = [
          this.erc20.address, 
          price, 
          now + 100000, 
        ]
        const seriesParams = [
          alice.address,  
          saleParams,
          10000,
          baseURI
        ];
        await this.nft.connect(owner).setSeriesInfo(seriesId, seriesParams);  
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.erc20.connect(bob).approve(this.nft.address, price);
        await this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ONE);
        expect(await this.nft.hooksCountByToken(id)).to.be.equal(ONE);
        const hooks = await this.nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(this.hook1.address);
        expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
      })

      it("shouldn't buy if hook number changed (token test)", async() => {
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
        await expect(this.nft.connect(bob)["buy(uint256,address,uint256,bool,uint256)"](id, this.erc20.address, price, false, ONE)).to.be.revertedWith("wrong hookNumber");
      })

      it("should correct set several hooks", async() => {
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
        await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, TWO, {value: price});
        expect(await this.nft.hooksCountByToken(id)).to.be.equal(TWO);
        const hooks = await this.nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(this.hook1.address);
        expect(hooks[1]).to.be.equal(this.hook2.address);
        expect(await this.hook1.numberOfCalls()).to.be.equal(ONE);
        expect(await this.hook2.numberOfCalls()).to.be.equal(ONE);
      })

      it("shouldnt aplly new hook for existing token", async() => {
        await this.nft.pushTokenTransferHook(seriesId, this.hook1.address);
        await this.nft.pushTokenTransferHook(seriesId, this.hook2.address);
        await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, TWO, {value: price});
        await this.nft.pushTokenTransferHook(seriesId, this.hook3.address);
        await this.nft.connect(bob).transferFrom(bob.address, charlie.address, id);
        expect(await this.hook1.numberOfCalls()).to.be.equal(TWO);
        expect(await this.hook2.numberOfCalls()).to.be.equal(TWO);
        expect(await this.hook3.numberOfCalls()).to.be.equal(ZERO);

        await this.nft.connect(charlie)["buy(uint256,bool,uint256)"](id.add(ONE), false, THREE, {value: price});
        expect(await this.hook1.numberOfCalls()).to.be.equal(THREE);
        expect(await this.hook2.numberOfCalls()).to.be.equal(THREE);
        expect(await this.hook3.numberOfCalls()).to.be.equal(ONE);

        expect(await this.nft.hooksCountByToken(id)).to.be.equal(TWO);
        expect(await this.nft.hooksCountByToken(id.add(ONE))).to.be.equal(THREE);
        const hooks = await this.nft.getHookList(seriesId);
        expect(hooks[0]).to.be.equal(this.hook1.address);
        expect(hooks[1]).to.be.equal(this.hook2.address);
        expect(hooks[2]).to.be.equal(this.hook3.address);

      })

    })

    describe("safe buy tests with contract ", async() => {
      it("should correct safe buy for contract", async() => {
        await this.buyer.buy(this.nft.address, id, true, ZERO, {value: price});
        expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
        expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
      })

      it("should correct safe transfer to contract", async() => {
        await this.nft.connect(bob)["buy(uint256,bool,uint256)"](id, false, ZERO, {value: price});
        await this.nft.connect(bob).listForSale(id, price, ZERO_ADDRESS, 10000);
        await this.buyer.buy(this.nft.address, id, true, ZERO, {value: price});
        expect(await this.nft.balanceOf(this.buyer.address)).to.be.equal(ONE);
        expect(await this.nft.ownerOf(id)).to.be.equal(this.buyer.address);
      })

    })
    // TODO mint and list on sale for someBody

  })
  


});

// UNIT TESTS:
// balanceOf()
// ownerOf()
// setSaleInfo()
// setSeriesInfo()
// listOnSale

// USER CASES:
// Alice creates collection

