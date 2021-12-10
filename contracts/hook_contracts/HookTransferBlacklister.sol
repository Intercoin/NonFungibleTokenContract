// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../SafeHook.sol";

contract HookTransferBlacklister is SafeHook, Ownable {
    mapping (address => bool) public blacklisted;

    function addToBlackList(address[] memory users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            blacklisted[users[i]] = true;
        }
    }

    function removeFromBlackList(address[] memory users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            blacklisted[users[i]] = false;
        }
    }
    function transferHook(address from, address to, uint256 tokenId) external view override returns(bool success) {
        require(!blacklisted[from], "sender is blacklisted");
        require(!blacklisted[to], "receiver is blacklisted");
        return true;
    }


}