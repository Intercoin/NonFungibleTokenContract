// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFT {
    struct SaleInfo { 
        uint64 onSaleUntil; 
        address currency;
        uint256 price;
        uint256 autoincrement;
    }

    struct CommissionInfo { // using to setup global commission
        uint64 maxValue;
        uint64 minValue;
        CommissionData ownerCommission;
    }

    struct CommissionData {
        uint64 value; // TODO: may be need a uint256 ?   it's not fraction
        address recipient;
    }

    struct SeriesInfo { 
        address payable author;
        uint32 limit;
        SaleInfo saleInfo;
        CommissionData commission;
        string baseURI;
        string suffix;
    }


}
