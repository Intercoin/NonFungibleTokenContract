// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/ICommunity.sol";

library LibCommunity{
    
    struct Settings {
        address addr;
        string roleMint;
    }
    
    
    /**
     * return true if {roleName} exist in Community contract for msg.sender
     * @param roleName role name
     */
    function _canRecord(
        Settings storage settings,
        string memory roleName
    ) 
        external 
        view 
        returns(bool s)
    {
        //s = false;
        if (settings.addr == address(0)) {
            // if the community address set to zero then we must skip the check
            s = true;
        } else {
            string[] memory roles = ICommunity(settings.addr).getRoles(msg.sender);
            for (uint256 i=0; i< roles.length; i++) {
                
                if (keccak256(abi.encodePacked(roleName)) == keccak256(abi.encodePacked(roles[i]))) {
                    s = true;
                }
            }
        }

    }
    
}