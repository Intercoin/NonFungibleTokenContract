// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./INFTSales.sol";
import "./INFTSalesFactory.sol";
import "./INFT.sol";

import "../whitelist/Whitelist.sol";

contract NFTSalesFactory is Ownable, INFTSalesFactory, Whitelist {
    using Clones for address;
    using EnumerableSet for EnumerableSet.AddressSet;

     /**
    * @custom:shortd Community implementation address
    * @notice Community implementation address
    */
    address public immutable implementationNftSale;
    
    bytes32 constant internal instancesListGroupName = "instancesList";
    bytes32 constant internal blackListGroupName = "blackList";

    struct InstanceInfo {
        address NFTcontract;        
        address owner;
        address currency;
        uint256 price;
        address beneficiary;
        uint64 duration;
    }
    mapping(address => InstanceInfo) instancesInfo;

    event InstanceCreated(address instance, uint instancesCount);

    modifier onlyInstance() {
        require(_isWhitelisted(instancesListGroupName, _msgSender()), "instances only");
        require(!_isWhitelisted(blackListGroupName, _msgSender()), "instance in black list");
        _;
    }
    /**
    */
    constructor(
        address implementation
    ) 
        Whitelist() 
    {
        require(implementation != address(0), "ZERO ADDRESS");
        implementationNftSale = implementation;
    }

    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    /**
    * @dev view amount of created instances
    * @return amount amount instances
    * @custom:shortd view amount of created instances
    */
    function instancesCount()
        external 
        view 
        returns (uint256 amount) 
    {
        amount = _whitelistCount(instancesListGroupName);
    }

    /**
    * @notice mint distribute nfts
    * @param tokenIds array of tokens that would be a minted
    * @param addresses array of desired owners to newly minted nft tokens
    * @custom:calledby instance
    * @custom:shortd mint distribute nfts
    */
    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external
        onlyInstance
    {
        
        address NFTcontract = instancesInfo[_msgSender()].NFTcontract;

        // get current owner directly from nft instance contract
        address owner = Ownable(NFTcontract).owner();
        
        bool transferSuccess;
        bytes memory returndata;

        // factory is a trusted forwarder for nft contract and calls makes as an owner
        (transferSuccess, returndata) = NFTcontract.call(
            abi.encodePacked(
                abi.encodeWithSelector(
                    INFT.mintAndDistribute.selector,
                    tokenIds, addresses
                ),
                owner
            )
        );
        _verifyCallResult(transferSuccess, returndata, "low level error");
    }

    /**
    * @notice view nft contrac address. used by instances in external calls
    * @custom:calledby instance
    * @custom:shortd view nft contrac address 
    */
    function getInstanceNFTcontract(
    ) 
        onlyInstance
        external 
        view 
        returns(address) 
    {
        return instancesInfo[_msgSender()].NFTcontract;
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * @notice creation NFTSales instance
    * @param NFTcontract nftcontract's address that allows to mintAndDistribute for this factory 
    * @param owner owner's adddress for newly created NFTSales contract
    * @param currency currency for every sale nft token 
    * @param price price amount for every sale nft token 
    * @param beneficiary address where which receive funds after sale
    * @param duration locked time when nft will be locked after sale
    * @return instance address of created instance `NFTSales`
    * @custom:calledby owner
    * @custom:shortd creation NFTSales instance
    */
    function produce(
        address NFTcontract,
        address owner, 
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) 
        public 
        onlyOwner
        returns (address instance) 
    {
        
        instance = address(implementationNftSale).clone();

        _produce(instance, owner, NFTcontract, currency, price, beneficiary, duration);
        
        INFTSales(instance).initialize(currency, price, beneficiary, duration);

        Ownable(instance).transferOwnership(owner);
        
        //_postProduce(instance);
        
    }

    /**
    * @notice remove ability to mintAndDistibute nft tokens for certain instance
    * @param instance instance's address that would be added to blacklist and prevent call mintAndDistibute
    * @custom:calledby owner
    * @custom:shortd adding instance to black list
    */
    function addToBlackList(address instance) 
        public 
        onlyOwner 
    {
        _whitelistAddSingle(blackListGroupName, instance);
    }

    /**
    * @notice remove ability to mintAndDistibute nft tokens for certain instance
    * @param instance instance's address that would be added to blacklist and prevent call mintAndDistibute
    * @custom:calledby owner
    * @custom:shortd adding instance to black list
    */
    function removeFromBlackList(address instance) 
        public 
        onlyOwner 
    {
        _whitelistRemoveSingle(blackListGroupName, instance);
    }

    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    function _produce(
        address instance,
        address owner, 
        address NFTcontract,
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) 
        internal
    {
        require(instance != address(0), "NFTSalesFactory: INSTANCE_CREATION_FAILED");

        _whitelistAddSingle(instancesListGroupName, instance);

        instancesInfo[instance] = InstanceInfo(NFTcontract, owner, currency, price, beneficiary, duration);
        
        emit InstanceCreated(instance, _whitelistCount(instancesListGroupName));
    }

    // function _postProduce(
    //     address instance
    // ) 
    //     internal
    // {
    // }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) 
        internal 
        pure 
        returns (bytes memory) 
    {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}