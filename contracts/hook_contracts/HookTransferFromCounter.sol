// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../SafeHook.sol";

contract HookTransferFromCounter is SafeHook {
    mapping (address => uint256) public transferFromNumber;
    function transferHook(address from, address to, uint256 tokenId) external override returns(bool success) {
        transferFromNumber[to]++;
        return true;
    }   


}