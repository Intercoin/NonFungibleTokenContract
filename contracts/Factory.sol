// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";

interface implementationContract {
    function initialize(string memory name_, string memory symbol_) external;
}

contract Factory is Ownable {
    address public implementation;
    mapping(bytes => address) public getInstance;
    address[] public instances;
    
    mapping(address => address) private _instanceCreators;
    
    struct InstanceInfo {
        string name;
        string symbol;
    }
    mapping(address => InstanceInfo) private _instanceInfos;
    
    event InstanceCreated(string name, string symbol, address instance, uint256 length);
    constructor (address instance) {
        implementation = instance;
    }

    function instancesCount() external view returns (uint256) {
        return instances.length;
    }

    function produce(
        string memory name,
        string memory symbol
    ) 
        public 
        returns (address instance) 
    {
        // 1% from LP tokens should move to owner while user try to redeem
        return _produce(name, symbol);
    }
    
    function getInstanceInfo(
        string memory name,
        string memory symbol
    ) public view returns(InstanceInfo memory) {
        
        address instance = getInstance[abi.encodePacked(name, symbol)];
        return _instanceInfos[instance];
    }
    
    function _produce(
        string memory name,
        string memory symbol
    ) internal returns (address instance) {
        instance = _createInstanceValidate(name, symbol);
        address payable instanceCreated = payable(_createInstance(name, symbol));
        require(instanceCreated != address(0), "StakingFactory: INSTANCE_CREATION_FAILED");
        implementationContract(instanceCreated).initialize(name, symbol);
        Ownable(instanceCreated).transferOwnership(_msgSender());
        instance = instanceCreated;        
    }
    
    function _createInstanceValidate(
        string memory name,
        string memory symbol
    ) internal view returns (address instance) {
        require((bytes(name)).length != 0, "Factory: EMPTY NAME");
        require((bytes(symbol)).length != 0, "Factory: EMPTY SYMBOL");
        instance = getInstance[abi.encodePacked(name, symbol)];
        require(instance == address(0), "Factory: ALREADY_EXISTS");
    }

    function _createInstance(
        string memory name,
        string memory symbol
    ) internal returns (address instance) {
        
        instance = createClone(implementation);
        
        getInstance[abi.encodePacked(name, symbol)] = instance;
        instances.push(instance);
        _instanceCreators[instance] = msg.sender;
        _instanceInfos[instance] = InstanceInfo(
            name,
            symbol
        );
        emit InstanceCreated(name, symbol, instance, instances.length);
    }

    function createClone(address target) internal returns (address result) {
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
