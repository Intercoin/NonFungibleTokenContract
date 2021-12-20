// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;
import "../extensions/ERC721SafeHooksUpgradeable.sol";
/**
* NFT with hooks support
*/
contract NFTSafeHook is ERC721SafeHooksUpgradeable {

    /**
    * @notice initializes contract
    */
    function initialize(
        string memory name_, 
        string memory symbol_, 
        string memory contractURI_,
        address utilityToken_
    ) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721SafeHook_init(name_, symbol_, utilityToken_);
        _contractURI = contractURI_;

    }
}
