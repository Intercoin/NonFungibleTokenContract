// const { ethers, waffle } = require('hardhat');
// const { BigNumber } = require('ethers');
// const { expect } = require('chai');
// const chai = require('chai');

// const TOTALSUPPLY = ethers.utils.parseEther('1000000000');    
// const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

// const ZERO = BigNumber.from('0');
// const ONE = BigNumber.from('1');
// const TWO = BigNumber.from('2');
// const THREE = BigNumber.from('3');
// const TEN = BigNumber.from('10');
// const HUN = BigNumber.from('100');


// chai.use(require('chai-bignumber')());
    
//   describe('ERC721', async() => {
//     const accounts = waffle.provider.getWallets();

//     const owner = accounts[0];
//     const approved = accounts[1];
//     const anotherApproved = accounts[2];
//     const operator = accounts[3];
//     const other = accounts[4];
//     const name = 'Non Fungible Token';
//     const symbol = 'NFT';
    
//     const seriesId = BigNumber.from('1000');

//     const firstTokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(BigNumber.from('5042'));;
//     const secondTokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(BigNumber.from('79217'));;
//     const nonExistentTokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(BigNumber.from('13'));;
//     const fourthTokenId = seriesId.mul(TWO.pow(BigNumber.from('192'))).add(BigNumber.from('4'));;
//     const baseURI = 'https://api.example.com/v1/';
//     const limit = BigNumber.from('10000');
//     const price = ethers.utils.parseEther('1');
//     const now = Math.round(Date.now() / 1000);   
//     const seriesParams = [
//       owner.address,  
//       ZERO_ADDRESS, 
//       price, 
//       now + 100000, 
//       baseURI,
//       limit
//     ];
  
//     beforeEach(async function () {
//         const NFTFactory = await ethers.getContractFactory("ERC721UpgradeableExt");
//         this.token = await NFTFactory.deploy();
//         await this.token.initialize(name, symbol);
//         await this.token.connect(owner).setSeriesInfo(seriesId, seriesParams);
//         await this.token.connect(owner)["buy(uint256)"](firstTokenId, {value: price}); 
//         await this.token.connect(owner)["buy(uint256)"](secondTokenId, {value: price}); 
//         this.toWhom = other.address; // default to other for toWhom in context-dependent tests
//     });

//     describe('balanceOf', function () {
//         describe('when the given address owns some tokens', function () {
//           it('returns the amount of tokens owned by the given address + series limit', async function () {
//             expect(await this.token.balanceOf(owner.address)).to.be.equal(TWO.add(limit));
//           });
//         });
  
//         describe('when the given address does not own any tokens', function () {
//           it('returns 0', async function () {
//             expect(await this.token.balanceOf(other.address)).to.be.equal('0');
//           });
//         });
  
//         describe('when querying the zero address', function () {
//           it('throws', async function () {
//             await expect(
//                this.token.balanceOf(ZERO_ADDRESS)).to.be.revertedWith('ERC721: balance query for the zero address');
//           });
//         });
//       });

//       describe('transfers', function () {
//         const tokenId = firstTokenId;
//         const data = '0x42';
  
//         let logs = null;
  
//         beforeEach(async function () {
//           await this.token.approve(approved.address, tokenId);
//           await this.token.setApprovalForAll(operator.address, true);
//         });

//         it('TEST', async() => {
//             await this.token.transferFrom(owner.address, this.toWhom.address, tokenId);

//         })
  
//         // const transferWasSuccessful = function ({ owner, tokenId, approved }) {
//         //   it('transfers the ownership of the given token ID to the given address', async function () {
//         //     expect(await this.token.ownerOf(tokenId)).to.be.equal(this.toWhom.address);
//         //   });
  
//         // //   it('emits a Transfer event', async function () {
//         // //     expectEvent.inLogs(logs, 'Transfer', { from: owner.address, to: this.toWhom.address, tokenId: tokenId });
//         // //   });
  
//         //   it('clears the approval for the token ID', async function () {
//         //     expect(await this.token.getApproved(tokenId)).to.be.equal(ZERO_ADDRESS);
//         //   });
  
//         // //   it('emits an Approval event', async function () {
//         // //     expectEvent.inLogs(logs, 'Approval', { owner.address, approved: ZERO_ADDRESS, tokenId: tokenId });
//         // //   });
  
//         //   it('adjusts owners balances', async function () {
//         //     expect(await this.token.balanceOf(owner.address)).to.be.bignumber.equal('1');
//         //   });
  
//         //   it('adjusts owners tokens by index', async function () {
//         //     if (!this.token.tokenOfOwnerByIndex) return;
  
//         //     expect(await this.token.tokenOfOwnerByIndex(this.toWhom.address, 0)).to.be.bignumber.equal(tokenId);
  
//         //     expect(await this.token.tokenOfOwnerByIndex(owner.address, 0)).to.be.bignumber.not.equal(tokenId);
//         //   });
//         // };
  
//         // const shouldTransferTokensByUsers = function (transferFunction) {
//         //   describe('when called by the owner', function () {
//         //     beforeEach(async function () {
//         //       ({ logs } = await transferFunction.call(this, owner.address, this.toWhom.address, tokenId, { from: owner }));
//         //     });
//         //     transferWasSuccessful({ owner, tokenId, approved });
//         //   });
  
//         //   describe('when called by the approved individual', function () {
//         //     beforeEach(async function () {
//         //       ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: approved }));
//         //     });
//         //     transferWasSuccessful({ owner, tokenId, approved });
//         //   });
  
//         //   describe('when called by the operator', function () {
//         //     beforeEach(async function () {
//         //       ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: operator }));
//         //     });
//         //     transferWasSuccessful({ owner, tokenId, approved });
//         //   });
  
//         //   describe('when called by the owner without an approved user', function () {
//         //     beforeEach(async function () {
//         //       await this.token.approve(ZERO_ADDRESS, tokenId);
//         //       ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: operator }));
//         //     });
//         //     transferWasSuccessful({ owner, tokenId, approved: null });
//         //   });
  
//         //   describe('when sent to the owner', function () {
//         //     beforeEach(async function () {
//         //       ({ logs } = await transferFunction.call(this, owner.address, owner.address, tokenId, { from: owner }));
//         //     });
  
//         //     it('keeps ownership of the token', async function () {
//         //       expect(await this.token.ownerOf(tokenId)).to.be.equal(owner.address);
//         //     });
  
//         //     it('clears the approval for the token ID', async function () {
//         //       expect(await this.token.getApproved(tokenId)).to.be.equal(ZERO_ADDRESS);
//         //     });
  
//         //     it('emits only a transfer event', async function () {
//         //       expectEvent.inLogs(logs, 'Transfer', {
//         //         from: owner,
//         //         to: owner,
//         //         tokenId: tokenId,
//         //       });
//         //     });
  
//         //     it('keeps the owner balance', async function () {
//         //       expect(await this.token.balanceOf(owner)).to.be.bignumber.equal('2');
//         //     });
  
//         //     it('keeps same tokens by index', async function () {
//         //       if (!this.token.tokenOfOwnerByIndex) return;
//         //       const tokensListed = await Promise.all(
//         //         [0, 1].map(i => this.token.tokenOfOwnerByIndex(owner, i)),
//         //       );
//         //       expect(tokensListed.map(t => t.toNumber())).to.have.members(
//         //         [firstTokenId.toNumber(), secondTokenId.toNumber()],
//         //       );
//         //     });
//         //   });
  
//         //   describe('when the address of the previous owner is incorrect', function () {
//         //     it('reverts', async function () {
//         //       await expectRevert(
//         //         transferFunction.call(this, other, other, tokenId, { from: owner }),
//         //         'ERC721: transfer of token that is not own',
//         //       );
//         //     });
//         //   });
  
//         //   describe('when the sender is not authorized for the token id', function () {
//         //     it('reverts', async function () {
//         //       await expectRevert(
//         //         transferFunction.call(this, owner, other, tokenId, { from: other }),
//         //         'ERC721: transfer caller is not owner nor approved',
//         //       );
//         //     });
//         //   });
  
//         //   describe('when the given token ID does not exist', function () {
//         //     it('reverts', async function () {
//         //       await expectRevert(
//         //         transferFunction.call(this, owner, other, nonExistentTokenId, { from: owner }),
//         //         'ERC721: operator query for nonexistent token',
//         //       );
//         //     });
//         //   });
  
//         //   describe('when the address to transfer the token to is the zero address', function () {
//         //     it('reverts', async function () {
//         //       await expectRevert(
//         //         transferFunction.call(this, owner, ZERO_ADDRESS, tokenId, { from: owner }),
//         //         'ERC721: transfer to the zero address',
//         //       );
//         //     });
//         //   });
//         // };
  
//         describe('via transferFrom', async() => {
//         //   shouldTransferTokensByUsers(function (from, to, tokenId, opts) {
//         //     return this.token.transferFrom(from, to, tokenId, opts);
//         //   });
//             describe('when called by the owner', async() => {
//               await this.token.transferFrom(owner.address, this.toWhom.address, tokenId);
//             //   beforeEach(async function () {
//             //     ({ logs } = await transferFunction.call(this, owner.address, this.toWhom.address, tokenId, { from: owner }));
//             //   });
//             //   transferWasSuccessful({ owner, tokenId, approved });
//             });
    
//             // describe('when called by the approved individual', function () {
//             //   beforeEach(async function () {
//             //     ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: approved }));
//             //   });
//             //   transferWasSuccessful({ owner, tokenId, approved });
//             // });
    
//             // describe('when called by the operator', function () {
//             //   beforeEach(async function () {
//             //     ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: operator }));
//             //   });
//             //   transferWasSuccessful({ owner, tokenId, approved });
//             // });
    
//             // describe('when called by the owner without an approved user', function () {
//             //   beforeEach(async function () {
//             //     await this.token.approve(ZERO_ADDRESS, tokenId);
//             //     ({ logs } = await transferFunction.call(this, owner.address, this.toWhom, tokenId, { from: operator }));
//             //   });
//             //   transferWasSuccessful({ owner, tokenId, approved: null });
//             // });
    
//             // describe('when sent to the owner', function () {
//             //   beforeEach(async function () {
//             //     ({ logs } = await transferFunction.call(this, owner.address, owner.address, tokenId, { from: owner }));
//             //   });
    
//             //   it('keeps ownership of the token', async function () {
//             //     expect(await this.token.ownerOf(tokenId)).to.be.equal(owner.address);
//             //   });
    
//             //   it('clears the approval for the token ID', async function () {
//             //     expect(await this.token.getApproved(tokenId)).to.be.equal(ZERO_ADDRESS);
//             //   });
    
//             //   it('emits only a transfer event', async function () {
//             //     expectEvent.inLogs(logs, 'Transfer', {
//             //       from: owner,
//             //       to: owner,
//             //       tokenId: tokenId,
//             //     });
//             //   });
    
//             //   it('keeps the owner balance', async function () {
//             //     expect(await this.token.balanceOf(owner)).to.be.bignumber.equal('2');
//             //   });
    
//             //   it('keeps same tokens by index', async function () {
//             //     if (!this.token.tokenOfOwnerByIndex) return;
//             //     const tokensListed = await Promise.all(
//             //       [0, 1].map(i => this.token.tokenOfOwnerByIndex(owner, i)),
//             //     );
//             //     expect(tokensListed.map(t => t.toNumber())).to.have.members(
//             //       [firstTokenId.toNumber(), secondTokenId.toNumber()],
//             //     );
//             //   });
//             // });
    
//             // describe('when the address of the previous owner is incorrect', function () {
//             //   it('reverts', async function () {
//             //     await expectRevert(
//             //       transferFunction.call(this, other, other, tokenId, { from: owner }),
//             //       'ERC721: transfer of token that is not own',
//             //     );
//             //   });
//             // });
    
//             // describe('when the sender is not authorized for the token id', function () {
//             //   it('reverts', async function () {
//             //     await expectRevert(
//             //       transferFunction.call(this, owner, other, tokenId, { from: other }),
//             //       'ERC721: transfer caller is not owner nor approved',
//             //     );
//             //   });
//             // });
    
//             // describe('when the given token ID does not exist', function () {
//             //   it('reverts', async function () {
//             //     await expectRevert(
//             //       transferFunction.call(this, owner, other, nonExistentTokenId, { from: owner }),
//             //       'ERC721: operator query for nonexistent token',
//             //     );
//             //   });
//             // });
    
//             // describe('when the address to transfer the token to is the zero address', function () {
//             //   it('reverts', async function () {
//             //     await expectRevert(
//             //       transferFunction.call(this, owner, ZERO_ADDRESS, tokenId, { from: owner }),
//             //       'ERC721: transfer to the zero address',
//             //     );
//             //   });
//             // });
          
//         });
  
//         // describe('via safeTransferFrom', function () {
//         //   const safeTransferFromWithData = function (from, to, tokenId, opts) {
//         //     return this.token.methods['safeTransferFrom(address,address,uint256,bytes)'](from, to, tokenId, data, opts);
//         //   };
  
//         //   const safeTransferFromWithoutData = function (from, to, tokenId, opts) {
//         //     return this.token.methods['safeTransferFrom(address,address,uint256)'](from, to, tokenId, opts);
//         //   };
  
//         //   const shouldTransferSafely = function (transferFun, data) {
//         //     describe('to a user account', function () {
//         //       shouldTransferTokensByUsers(transferFun);
//         //     });
  
//         //     describe('to a valid receiver contract', function () {
//         //       beforeEach(async function () {
//         //         const ERC721ReceiverMock = await ethers.getContractFactory("ERC721ReceiverMock");
//         //         this.receiver = await ERC721ReceiverMock.deploy(RECEIVER_MAGIC_VALUE, Error.None);
        
//         //         this.toWhom = this.receiver.address;
//         //       });
  
//         //       shouldTransferTokensByUsers(transferFun);
  
//         //       it('calls onERC721Received', async function () {
//         //         const receipt = await transferFun.call(this, owner, this.receiver.address, tokenId, { from: owner });
  
//         //         await expectEvent.inTransaction(receipt.tx, ERC721ReceiverMock, 'Received', {
//         //           operator: owner,
//         //           from: owner,
//         //           tokenId: tokenId,
//         //           data: data,
//         //         });
//         //       });
  
//         //       it('calls onERC721Received from approved', async function () {
//         //         const receipt = await transferFun.call(this, owner, this.receiver.address, tokenId, { from: approved });
  
//         //         await expectEvent.inTransaction(receipt.tx, ERC721ReceiverMock, 'Received', {
//         //           operator: approved,
//         //           from: owner,
//         //           tokenId: tokenId,
//         //           data: data,
//         //         });
//         //       });
  
//         //       describe('with an invalid token id', function () {
//         //         it('reverts', async function () {
//         //           await expectRevert(
//         //             transferFun.call(
//         //               this,
//         //               owner,
//         //               this.receiver.address,
//         //               nonExistentTokenId,
//         //               { from: owner },
//         //             ),
//         //             'ERC721: operator query for nonexistent token',
//         //           );
//         //         });
//         //       });
//         //     });
//         //   };
  
//         //   describe('with data', function () {
//         //     shouldTransferSafely(safeTransferFromWithData, data);
//         //   });
  
//         //   describe('without data', function () {
//         //     shouldTransferSafely(safeTransferFromWithoutData, null);
//         //   });
  
//         //   describe('to a receiver contract returning unexpected value', function () {
//         //     it('reverts', async function () {
//         //       const invalidReceiver = await ERC721ReceiverMock.new('0x42', Error.None);
//         //       await expectRevert(
//         //         this.token.safeTransferFrom(owner, invalidReceiver.address, tokenId, { from: owner }),
//         //         'ERC721: transfer to non ERC721Receiver implementer',
//         //       );
//         //     });
//         //   });
  
//         //   describe('to a receiver contract that reverts with message', function () {
//         //     it('reverts', async function () {
//         //       const revertingReceiver = await ERC721ReceiverMock.new(RECEIVER_MAGIC_VALUE, Error.RevertWithMessage);
//         //       await expectRevert(
//         //         this.token.safeTransferFrom(owner, revertingReceiver.address, tokenId, { from: owner }),
//         //         'ERC721ReceiverMock: reverting',
//         //       );
//         //     });
//         //   });
  
//         //   describe('to a receiver contract that reverts without message', function () {
//         //     it('reverts', async function () {
//         //       const revertingReceiver = await ERC721ReceiverMock.new(RECEIVER_MAGIC_VALUE, Error.RevertWithoutMessage);
//         //       await expectRevert(
//         //         this.token.safeTransferFrom(owner, revertingReceiver.address, tokenId, { from: owner }),
//         //         'ERC721: transfer to non ERC721Receiver implementer',
//         //       );
//         //     });
//         //   });
  
//         //   describe('to a receiver contract that panics', function () {
//         //     it('reverts', async function () {
//         //       const revertingReceiver = await ERC721ReceiverMock.new(RECEIVER_MAGIC_VALUE, Error.Panic);
//         //       await expectRevert.unspecified(
//         //         this.token.safeTransferFrom(owner, revertingReceiver.address, tokenId, { from: owner }),
//         //       );
//         //     });
//         //   });
  
//         //   describe('to a contract that does not implement the required function', function () {
//         //     it('reverts', async function () {
//         //       const nonReceiver = this.token;
//         //       await expectRevert(
//         //         this.token.safeTransferFrom(owner, nonReceiver.address, tokenId, { from: owner }),
//         //         'ERC721: transfer to non ERC721Receiver implementer',
//         //       );
//         //     });
//         //   });
//         // });
//       });
//   });