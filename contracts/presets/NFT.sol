// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;
pragma abicoder v2;
import "../ERC721UpgradeableExt.sol";
import "../interfaces/IInstanceContract.sol";

contract NFT is ERC721UpgradeableExt, IInstanceContract {

    function initialize(
        string memory name_, 
        string memory symbol_,
        string memory contractURI_, 
        string memory baseURI_, 
        string memory suffixURI_, 
        address costManager_,
        address msgSender_

    ) 
        public 
        override
        initializer 
    {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721_init(name_, symbol_, costManager_, msgSender_);
        _contractURI = contractURI_;
        baseURI = baseURI_;
        suffix = suffixURI_;
    }

}
