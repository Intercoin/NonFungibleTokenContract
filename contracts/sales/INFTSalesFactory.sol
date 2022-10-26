// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface INFTSalesFactory {
    function mintAndDistribute(uint256[] memory tokenIds, address[] memory addresses) external;

    function getInstanceNFTcontract() external view returns (address addr);

    function whitelistByNFT(address NFTContract) external view returns (address[] memory instances);
    // function name() view external returns(string memory);
    // function symbol() view external returns(string memory);
    // function owner() view external returns(address);
}
