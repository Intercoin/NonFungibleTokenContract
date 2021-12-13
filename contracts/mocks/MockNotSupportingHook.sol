// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../SafeHook.sol";

contract MockNotSupportingHook is SafeHook {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return false;
    }
    function executeHook(address from, address to, uint256 tokenId) external override returns(bool success) {
        return false;
    }


}