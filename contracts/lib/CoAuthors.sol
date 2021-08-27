// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

library CoAuthors{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    using SafeMathUpgradeable for uint256;
    
    struct List {
        mapping(address => uint256) proportions;
        EnumerableSetUpgradeable.AddressSet addresses;
    }
    
    struct Ratio {
        address addr;
        uint256 proportion;
    }
    
    
    function addBulk(List storage list, address[] memory addresses, uint256[] memory proportions) external returns (bool) {
        
        _empty(list);
        
        uint256 i;
        for (i = 0; i < addresses.length; i++) {
            
            list.addresses.add(addresses[i]);
            list.proportions[addresses[i]] = proportions[i];
            
        }
        
        return true;
    }
    function empty(List storage list) external {
        
        // make a trick. 
        // remove all items and push new. checking on duplicate values in progress
        for (uint256 i =0; i<list.addresses._inner._values.length; i++) {
            delete list.addresses._inner._indexes[list.addresses._inner._values[i]];
        }
        delete list.addresses._inner._values;
    }
    
    function add(List storage list, address addr, uint256 proportion) external returns (bool) {
        
        list.addresses.add(addr);
        list.proportions[addr] = proportion;
            
        return true;
    }
    
    function smartAdd(List storage list, Ratio[] memory ratio, address author) external returns (bool) {
        uint256 tmpProportions;
        for (uint256 i = 0; i < ratio.length; i++) {
            
            require (ratio[i].addr != author, "author can not be in list");
            require (list.addresses.contains(ratio[i].addr) == false, "can not have a duplicate values");
            require (ratio[i].proportion != 0, "proportions can not be zero value");
            
            tmpProportions = tmpProportions.add(ratio[i].proportion);
            
            //add(list, ratio[i].addr, ratio[i].proportion);
            list.addresses.add(ratio[i].addr);
            list.proportions[ratio[i].addr] = ratio[i].proportion;
            //---
        
        }
        require (tmpProportions <= 100, "total proportions can not be more than 100%");
        
            
        return true;
    }
    
    function contains(List storage list, address newAuthor) external view returns(bool) {
        return list.addresses.contains(newAuthor);
    }
    
    function removeIfExists(List storage list, address newAuthor) external {
        if (list.addresses.contains(newAuthor) == true) {
            list.addresses.remove(newAuthor);
        }
    }
    
    function length(List storage list) external view returns(uint256) {
        return list.addresses.length();
    }
    
    function at(List storage list, uint256 i) external view returns(address, uint256) {
        address addr = list.addresses.at(i);
        return (addr, list.proportions[addr]);
    }
    
    function _empty(List storage list) private {
        
        // make a trick. 
        // remove all items and push new. checking on duplicate values in progress
        for (uint256 i =0; i<list.addresses._inner._values.length; i++) {
            delete list.addresses._inner._indexes[list.addresses._inner._values[i]];
        }
        delete list.addresses._inner._values;
    }
}
