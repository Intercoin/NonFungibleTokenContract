// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../SafeHook.sol";

contract MockHook is SafeHook {

    uint256 public numberOfCalls;

    function transferHook(address from, address to, uint256 tokenId) external override returns(bool success) {
        numberOfCalls++;
        return true;
    }


}