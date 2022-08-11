// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "../interfaces/IFactory.sol";

abstract contract CostManager  {

    
    // Utility token, if any, to manage during operations
    address public costManager;

    // Address of factory that produced this instance
    address public factory;
    
    
    /** 
    * @dev sets the utility token
    * @param costManager_ new address of utility token, or 0
    */
    function overrideCostManager(address costManager_) external {
        // require factory owner or operator
        // otherwise needed deployer(!!not contract owner) in cases if was deployed manually
        require (
            (factory.isContract()) 
                ?
                    IFactory(factory).canOverrideCostManager(_msgSender(), address(this))
                :
                    factory == _msgSender()
            ,
            "cannot override"
        );
        costManager = costManager_;
    }
    
    // from contextx?
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    

}