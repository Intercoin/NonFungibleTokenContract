// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFT {
    
    // struct SaleInfo { 
    //     uint64 onSaleUntil; 
    //     address currency;
    //     uint256 price;
    //     uint256 autoincrement;
    // }
    // struct CommissionData {
    //     uint64 value;
    //     address recipient;
    // }
    // function getTokenSaleInfo(uint256 tokenId) external view returns(bool isOnSale, bool exists, SaleInfo memory data, address owner);
    function mintAndDistribute(uint256[] memory tokenIds, address[] memory addresses) external ;

    
}   