// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./erc721ext/ERC721UpgradeableExt.sol";

contract NFTV2 is ERC721UpgradeableExt {

     /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function initialize(string memory name_, string memory symbol_) public initializer {
        __ERC721_init(name_, symbol_);
       
    }

}