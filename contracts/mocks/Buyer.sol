// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./ERC721ReceiverMock.sol";
import "../ERC721UpgradeableExt.sol";

contract Buyer is ERC721ReceiverMock {

    constructor(bytes4 retval, Error error) ERC721ReceiverMock(retval, error) {
        
    }

    function buy(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
        ERC721UpgradeableExt(target).buy{value: msg.value}(tokenId, msg.value, safe, hookNumber);
    }
}