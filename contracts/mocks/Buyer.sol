// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./ERC721ReceiverMock.sol";
import "../NFT.sol";
import "./IMockBuyV2.sol";

contract Buyer is ERC721ReceiverMock {

    constructor(bytes4 retval, Error error) ERC721ReceiverMock(retval, error) {
        
    }

    function buy(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        //NFT(target).buy{value: msg.value}(tokenId, msg.value, safe, hookNumber);
        NFT(target).buy{value: msg.value}(
            tokenIds, 
            address(0),
            msg.value, 
            safe, 
            hookNumber,
            msg.sender
        );

        // buy(
        // uint256[] memory tokenIds,
        // address currency,
        // uint256 totalPrice,
        // bool safe,
        // uint256 hookCount,
        // address buyFor
        // ) 

    }

    function buyV2(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
        uint256[] memory t;
        t = new uint256[](1);
        t[0]=tokenId;
        IMockBuyV2(target).buy{value: msg.value}(t, 0x0000000000000000000000000000000000000000, msg.value, safe, hookNumber, address(this));
    }
}