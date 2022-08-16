// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFTSales {
    function initialize(
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) external;

    function specialPurchase(uint256[] memory tokenIds, address[] memory addresses) external payable;

    
    function remainingDays(uint256 tokenId) external view returns(uint64);
    function distributeUnlockedTokens(uint256[] memory tokenIds) external;
    function claim(uint256[] memory tokenIds) external;

    
}