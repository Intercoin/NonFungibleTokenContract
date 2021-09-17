// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFT.sol";


contract NFTMock is NFT {
    
    function getCurrTime() public view returns(uint256) {return block.timestamp;}
}