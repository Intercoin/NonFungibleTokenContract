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
    function autorizeMintAndDistributeAuto(uint64 seriesId, address account, uint256 amount) external payable;
    
    function remainingDays(uint256 tokenId) external view returns(uint64);
    function distributeUnlockedTokens(uint256[] memory tokenIds) external;
    function claim(uint256[] memory tokenIds) external;

    function isWhitelisted(address account) external view returns(bool);
    function isWhitelistedAuto(address account, uint64 seriesId) external view returns(bool);

    function specialPurchasesListAdd(address[] memory addresses) external;
    function specialPurchasesListRemove(address[] memory addresses) external ;
    function mintWhitelistAdd(uint64 seriesId, address[] memory addresses) external;
    function mintWhitelistRemove(uint64 seriesId, address[] memory addresses) external;
    function setAutoIndex(uint64 seriesId, uint192 index) external;
}