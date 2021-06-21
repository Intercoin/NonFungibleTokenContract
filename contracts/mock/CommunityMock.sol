// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "../interfaces/ICommunity.sol";

contract CommunityMock is ICommunity {
    uint256 count = 5;
    
    function memberCount(string memory role) public override view returns(uint256) {
        return count;
    }
    function setMemberCount(uint256 _count) public {
        count = _count;
    }
    
    function getRoles(address member)public override view returns(string[] memory){
        string[] memory list = new string[](5);
        list[0] = 'owners';
        list[1] = 'admins';
        list[2] = 'members';
        list[3] = 'sub-admins';
        list[4] = 'unkwnowns';
        return list;
        
    }
    function getMember(string memory role) public override view returns(address[] memory){
        address[] memory list = new address[](0);
        return list;
    }
    
}
