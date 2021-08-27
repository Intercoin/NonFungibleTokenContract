// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/INFTSeries.sol";
import "./FactoryBase.sol";

contract NFTSeriesFactory is FactoryBase {
    
    function produce(
        string memory name,
        string memory symbol,
        LibCommunity.Settings memory communitySettings
    ) public returns(address) {
        
        address proxy = _produce();

        INFTSeries(proxy).initialize(name, symbol, communitySettings);
        OwnableUpgradeable(proxy).transferOwnership(msg.sender);
        
        return proxy;
    }
    
}