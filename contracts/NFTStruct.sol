// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

abstract contract NFTStruct {
   // using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    struct CommunitySettings {
        address addr;
        string roleMint;
    }
    struct CommissionParams {
        address token; 
        uint256 amount;
        uint256 multiply;
        uint256 intervalSeconds;
    }
    struct CommissionSettings {
        address token; 
        uint256 amount;
        uint256 multiply;
        uint256 intervalSeconds;
        uint256 createdTs;
    }

    struct SalesData {
        mapping (address => uint256) offerPayAmount;
        EnumerableSetUpgradeable.AddressSet offerAddresses;
        uint256 amount;
        bool isSale;
    }
    
   
}