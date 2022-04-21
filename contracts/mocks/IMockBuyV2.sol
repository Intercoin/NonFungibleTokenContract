// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

interface IMockBuyV2 {
    function buy(
        uint256[] memory tokenIds,
        address currency,
        uint256 totalPrice,
        bool safe,
        uint256 hookCount,
        address buyFor
    ) external payable;
        
}