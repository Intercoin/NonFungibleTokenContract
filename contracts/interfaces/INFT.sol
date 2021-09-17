// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

interface INFT {
    struct CommunitySettings {
        address addr;
        string roleMint;
    }
    struct CommissionParams {
        address token; 
        uint256 amount;
        uint256 multiply;
        uint256 accrue;
        uint256 intervalSeconds;
        uint256 reduceCommission;
    }
    struct CommissionSettings {
        address token; 
        uint256 amount;
        uint256 multiply;
        uint256 accrue;
        uint256 intervalSeconds;
        uint256 reduceCommission;
        uint256 createdTs;
        uint256 lastTransferTs;
        mapping (address => uint256) offerPayAmount;
        EnumerableSetUpgradeable.AddressSet offerAddresses;
    }

    struct Bid {
        address bidder;
        uint256 bid;
    }
    struct SalesData {
        address erc20Address;
        uint256 amount;
        bool isSale;
        
        uint256 startTime;
        uint256 endTime;
        uint256 minIncrement;
        bool isAuction;
        
        Bid[] bids;
    }
    
    
    function initialize(string memory, string memory, CommunitySettings memory) external;
}
