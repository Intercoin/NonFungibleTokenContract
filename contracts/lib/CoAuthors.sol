// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

library CoAuthors{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    struct List {
        mapping(address => uint256) proportions;
        EnumerableSetUpgradeable.AddressSet addresses;
    }
    
    function addBulk(List storage list, address[] memory addresses, uint256[] memory proportions) internal returns (bool) {
        
        empty(list);
        
        uint256 i;
        for (i = 0; i < addresses.length; i++) {
            
            list.addresses.add(addresses[i]);
            list.proportions[addresses[i]] = proportions[i];
            
        }
        
        return true;
    }
    function empty(List storage list) internal {
        
        // make a trick. 
        // remove all items and push new. checking on duplicate values in progress
        for (uint256 i =0; i<list.addresses._inner._values.length; i++) {
            delete list.addresses._inner._indexes[list.addresses._inner._values[i]];
        }
        delete list.addresses._inner._values;
    }
    
    function add(List storage list, address addr, uint256 proportion) internal returns (bool) {
        
        list.addresses.add(addr);
        list.proportions[addr] = proportion;
            
        return true;
    }
    
    function contains(List storage list, address newAuthor) internal view returns(bool) {
        return list.addresses.contains(newAuthor);
    }
    
    function removeIfExists(List storage list, address newAuthor) internal {
        if (list.addresses.contains(newAuthor) == true) {
            list.addresses.remove(newAuthor);
        }
    }
    
    function length(List storage list) internal view returns(uint256) {
        return list.addresses.length();
    }
    
    function at(List storage list, uint256 i) internal view returns(address, uint256) {
        address addr = list.addresses.at(i);
        return (addr, list.proportions[addr]);
    }
    
    
}
