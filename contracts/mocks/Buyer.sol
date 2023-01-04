// // SPDX-License-Identifier: MIT

// pragma solidity 0.8.11;

// import "./ERC721ReceiverMock.sol";
// import "../extensions/ERC721SafeHooksUpgradeable.sol";
// import "./IMockBuyV2.sol";

// contract Buyer is ERC721ReceiverMock {

//     constructor(bytes4 retval, Error error) ERC721ReceiverMock(retval, error) {
        
//     }

//     function buy(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
//         ERC721SafeHooksUpgradeable(target).buy{value: msg.value}(tokenId, msg.value, safe, hookNumber);
//     }

//     function buyV2(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
//         uint256[] memory t;
//         t = new uint256[](1);
//         t[0]=tokenId;
//         IMockBuyV2(target).buy{value: msg.value}(t, 0x0000000000000000000000000000000000000000, msg.value, safe, hookNumber, address(this));
//     }
// }