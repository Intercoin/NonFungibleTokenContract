// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "../interfaces/ICommunity.sol";

contract MockCommunity  {
    uint256 private count = 5;

    string[5] list;

    function setRoles(string[5] memory list_) public {
        for (uint256 i=0; i<count; i++) {
            list[i] = list_[i];
        }
    }

    function getRoles(address/* member*/)public view returns(string[] memory){
        string[] memory listOut = new string[](5);
        for (uint256 i=0; i<count; i++) {
            listOut[i] = list[i];
        }
        return listOut;
        
    }


    function isMemberHasRole(
        address /* to*/, 
        string memory role
    ) external view returns(bool) {
        for (uint256 i=0; i<count; i++) {
            if ((keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked(list[i])))) {
                return true;
            }
            
        }
        return false;

    }


}