// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../interfaces/IFactory.sol";

import "./INFTInstanceContract.sol";
import "./NFTState.sol";
import "./NFTView.sol";

contract NFTFactory is Ownable, IFactory {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    address public costManager;
    address public implementation;
    mapping(bytes32 => address) public getInstance; // keccak256("name", "symbol") => instance address
    mapping(address => InstanceInfo) private _instanceInfos;
    address[] public instances;
    EnumerableSetUpgradeable.AddressSet private _renouncedOverrideCostManager;
       
    struct InstanceInfo {
        string name;
        string symbol;
        address creator;
    }
    
    event InstanceCreated(string name, string symbol, address instance, uint256 length);
    event RenouncedOverrideCostManagerForInstance(address instance);

    address public implementationNFTView;
    address public implementationNFTState;
    constructor (
        address instance, 
        address implState, 
        address implView, 
        address costManager_
    ) {
        implementation = instance;
        costManager = costManager_;

        implementationNFTState = implState;
        implementationNFTView = implView;
    }

    /**
    * @dev returns the count of instances
    */
    function instancesCount() external view returns (uint256) {
        return instances.length;
    }
    
    /**
    * @dev set the costManager for all future calls to produce()
    */
    function setCostManager(address costManager_) public onlyOwner {
        costManager = costManager_;
    }
    
    /**
    * @dev renounces ability to override cost manager on instances
    */
    function renounceOverrideCostManager(address instance) public onlyOwner {
        _renouncedOverrideCostManager.add(instance);
        emit RenouncedOverrideCostManagerForInstance(instance);
    }
    
    /** 
    * @dev instance can call this to find out whether a given address can set the cost manager contract
    * @param account the address to test
    * @param instance the instance to test
    */
    function canOverrideCostManager(
        address account, 
        address instance
    ) 
        external 
        override 
        view
        returns (bool) 
    {
        return (account == owner() && !_renouncedOverrideCostManager.contains(instance));
    }

    /**
    * @dev produces new instance with defined name and symbol
    * @param name name of new token
    * @param symbol symbol of new token
    * @param contractURI contract URI
    * @return instance address of new contract
    */
    function produce(
        string memory name,
        string memory symbol,
        string memory contractURI
    ) 
        public 
        returns (address instance) 
    {
        return _produce(
            name,
            symbol,
            contractURI,
            "",
            ""
        );
    }

    /**
    * @dev produces new instance with defined name and symbol
    * @param name name of new token
    * @param symbol symbol of new token
    * @param contractURI contract URI
    * @param baseURI base URI
    * @param suffixURI suffix URI
    * @return instance address of new contract
    */
    function produce(
        string memory name,
        string memory symbol,
        string memory contractURI,
        string memory baseURI,
        string memory suffixURI
    ) 
        public 
        returns (address instance) 
    {
        return _produce(
            name,
            symbol,
            contractURI,
            baseURI,
            suffixURI
        );
    }

    function _produce(
        string memory name,
        string memory symbol,
        string memory contractURI,
        string memory baseURI,
        string memory suffixURI

    ) 
        internal 
        returns (address instance) 
    {
        _createInstanceValidate(name, symbol);
        address instanceCreated = _createInstance(name, symbol);
        require(instanceCreated != address(0), "StakingFactory: INSTANCE_CREATION_FAILED");
        address ms = _msgSender();
        INFTInstanceContract(instanceCreated).initialize(
            implementationNFTState,
            implementationNFTView,
            name, 
            symbol, 
            contractURI, 
            baseURI,
            suffixURI,
            costManager, 
            ms
        );
        Ownable(instanceCreated).transferOwnership(ms);
        instance = instanceCreated;
    }

    
     /**
    * @dev returns instance info
    * @param instanceId instance ID
    */
    function getInstanceInfo(
        uint256 instanceId
    ) public view returns(InstanceInfo memory) {
        
        address instance = instances[instanceId];
        return _instanceInfos[instance];
    }
    
    
    function _createInstanceValidate(
        string memory name,
        string memory symbol
    ) internal view {
        require((bytes(name)).length != 0, "Factory: EMPTY NAME");
        require((bytes(symbol)).length != 0, "Factory: EMPTY SYMBOL");
        address instance = getInstance[keccak256(abi.encodePacked(name, symbol))];
        require(instance == address(0), "Factory: ALREADY_EXISTS");
    }

    function _createInstance(
        string memory name,
        string memory symbol
    ) internal returns (address instance) {
        
        instance = _createClone(implementation);
        
        getInstance[keccak256(abi.encodePacked(name, symbol))] = instance;
        instances.push(instance);
        _instanceInfos[instance] = InstanceInfo(
            name,
            symbol,
            _msgSender()
        );
        emit InstanceCreated(name, symbol, instance, instances.length);
    }

    function _createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
        let clone := mload(0x40)
        mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
        mstore(add(clone, 0x14), targetBytes)
        mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        result := create(0, clone, 0x37)
        }
    }
        
}
