// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/**
 * Realization a addresses whitelist
 * 
 */
abstract contract Whitelist is Context{
    using EnumerableSet for EnumerableSet.AddressSet;
    
    struct List {
        address addr;
        bool alsoGradual;
    }
    struct ListStruct {
        EnumerableSet.AddressSet indexes;
        mapping(address => List) data;
    }
    
    bytes32 internal commonGroupName;
    
    mapping(bytes32 => ListStruct) list;

    modifier onlyWhitelist(bytes32 groupName) {
        require(
            list[groupName].indexes.contains(_msgSender()) == true, 
            "Sender is not in whitelist"
        );
        _;
    }
    
    constructor() {
        commonGroupName = "common";
    }
    
    
    function _whitelistAdd(bytes32 groupName, address[] memory _addresses) internal returns (bool) {
        for (uint i = 0; i < _addresses.length; i++) {
            _whitelistAddSingle(groupName, _addresses[i]);
        }
        return true;
    }

    function _whitelistAddSingle(bytes32 groupName, address addr) internal {
        require(addr != address(0), "Whitelist: Contains the zero address");
        if (list[groupName].indexes.contains(addr) == true) {
            // already exist
        } else {
            list[groupName].indexes.add(addr);
            list[groupName].data[addr].addr = addr;
        }
    }
    
    function _whitelistRemove(bytes32 groupName, address[] memory _addresses) internal returns (bool) {
        for (uint i = 0; i < _addresses.length; i++) {
            _whitelistRemoveSingle(groupName, _addresses[i]);
        }
        return true;
    }

    function _whitelistRemoveSingle(bytes32 groupName, address addr) internal {
        if (list[groupName].indexes.remove(addr) == true) {
            delete list[groupName].data[addr];
        }
    }
    
    function _isWhitelisted(bytes32 groupName, address addr) internal view returns (bool) {
        return list[groupName].indexes.contains(addr);
    }

    function _whitelistCount(bytes32 groupName) internal view returns (uint256) {
        return list[groupName].indexes.length();
    }
  
}