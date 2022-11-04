// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFTSales {
    function initialize(uint64 seriesId, address currency, uint256 price, address beneficiary, uint192 autoindex, uint64 duration, uint32 rateInterval, uint16 rateAmount) external;
    function specialPurchase(address account, uint256 amount) external payable;
    function purchase(address account, uint256 amount) external payable;
    function remainingDays(uint256 tokenId) external view returns (uint64);
    function distributeUnlockedTokens(uint256[] memory tokenIds) external;
    function claim(uint256[] memory tokenIds) external;
    function isWhitelisted(address account) external view returns (bool);
    function specialPurchasesListAdd(address[] memory addresses) external;
    function specialPurchasesListRemove(address[] memory addresses) external;
    function setAutoIndex(uint192 index) external;
}
