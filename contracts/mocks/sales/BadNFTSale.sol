// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

// import "./ERC721ReceiverMock.sol";
// import "../extensions/ERC721SafeHooksUpgradeable.sol";
import "../../sales/INFTSalesFactory.sol";

contract BadNFTSale {
    function specialPurchase(
        address factoryAddress,
        uint256[] memory tokenIds,
        address[] memory addresses
    ) public payable {
        INFTSalesFactory(factoryAddress)._doMintAndDistribute(
            tokenIds,
            addresses
        );
    }
}
