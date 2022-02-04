// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "../SafeHook.sol";

contract MockWithoutFunctionHook  {
    function executeHook(address from, address to, uint256 tokenId) external returns(bool success) {
        return false;
    }


}