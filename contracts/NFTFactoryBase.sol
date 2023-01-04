// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./interfaces/IFactory.sol";


abstract contract NFTFactoryBase is Ownable, IFactory {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    address public costManager;

    EnumerableSetUpgradeable.AddressSet private _renouncedOverrideCostManager;

    event RenouncedOverrideCostManagerForInstance(address instance);
    
    constructor (
        address costManager_
    ) {
        
        costManager = costManager_;
    }
    
    /**
    * @dev set the costManager for all future calls to produce()
    */
    function setCostManager(address costManager_) public onlyOwner {
        costManager = costManager_;
    }
     
    /**
    * @dev renounces ability to override cost manager on instances
    */
    function renounceOverrideCostManager(address instance) public onlyOwner {
        _renouncedOverrideCostManager.add(instance);
        emit RenouncedOverrideCostManagerForInstance(instance);
    }

    /** 
    * @dev instance can call this to find out whether a given address can set the cost manager contract
    * @param account the address to test
    * @param instance the instance to test
    */
    function canOverrideCostManager(
        address account, 
        address instance
    ) 
        external 
        override 
        view
        returns (bool) 
    {
        return (account == owner() && !_renouncedOverrideCostManager.contains(instance));
    }

    
}