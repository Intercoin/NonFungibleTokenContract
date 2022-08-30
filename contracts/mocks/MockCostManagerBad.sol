// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "releasemanager/contracts/interfaces/ICostManager.sol";

contract MockCostManagerBad is ICostManager {
     function accountForOperation(
        address sender, 
        uint256 info, 
        uint256 param1, 
        uint256 param2
    ) 
        external 
        returns(uint256, uint256) 
    {
        revert("error in MockCostManagerBad");
    }
    
}
