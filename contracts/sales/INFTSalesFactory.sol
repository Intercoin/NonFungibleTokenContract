// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFTSalesFactory {
    function mintAndDistribute(uint256[] memory tokenIds, address[] memory addresses) external;
    function getInstanceNftAddress() external view returns(address);
    // function name() view external returns(string memory);
    // function symbol() view external returns(string memory);
    // function owner() view external returns(address);
}