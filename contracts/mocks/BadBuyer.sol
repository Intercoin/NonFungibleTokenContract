// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721ReceiverMock.sol";
import "../extensions/ERC721SafeHooksUpgradeable.sol";

contract BadBuyer {

    function buy(address target, uint256 tokenId, bool safe, uint256 hookNumber) external payable {
        ERC721SafeHooksUpgradeable(target).buy{value: msg.value}(tokenId, safe, hookNumber);
    }
}