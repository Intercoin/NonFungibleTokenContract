// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../SafeHook.sol";

contract HookTransferCounter is SafeHook {
    mapping (address => uint256) public transferNumber;
    function transferHook(address from, address to, uint256 tokenId) external override returns(bool success) {
        transferNumber[to]++;
        return true;
    }   


}