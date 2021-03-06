// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/INFT.sol";
import "./FactoryBase.sol";

contract NFTFactory is FactoryBase {
    
    function produce(
        string memory name,
        string memory symbol,
        INFT.CommunitySettings memory communitySettings
    ) public returns(address) {
        
        address proxy = _produce();

        INFT(proxy).initialize(name, symbol, communitySettings);
        OwnableUpgradeable(proxy).transferOwnership(msg.sender);
        
        return proxy;
    }
    
}