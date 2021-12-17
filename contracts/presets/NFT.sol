// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;
import "../ERC721UpgradeableExt.sol";

contract NFT is ERC721UpgradeableExt {

    function initialize(string memory name_, string memory symbol_, address utilityToken_) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721_init(name_, symbol_, utilityToken_);
    }

}
