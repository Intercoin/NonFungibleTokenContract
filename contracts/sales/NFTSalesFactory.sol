// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./INFTSales.sol";
import "./INFTSalesFactory.sol";
import "./INFT.sol";

//import "hardhat/console.sol";

contract NFTSalesFactory is INFTSalesFactory {
    using Clones for address;
    using EnumerableSet for EnumerableSet.AddressSet;

     /**
    * @custom:shortd Community implementation address
    * @notice Community implementation address
    */
    address public immutable implementationNFTSale;

    struct InstanceInfo {
        address NFTContract;
        address owner;
        address currency;
        uint256 price;
        address beneficiary;
        uint64 duration;
    }
    //      instance(NFTsale)
    mapping(address => InstanceInfo) public instancesInfo;

    // instances list which can call mintAndDistribute.
    // items can be add only by NFT owner(not NFTsales'owner!)
    // items can be removed only by NFT owner(not NFTsales'owner!)
    EnumerableSet.AddressSet whitelist;

    event InstanceCreated(address instance);

    error InstancesOnly();
    error OwnerOfNFTContractOnly(address currentNFTOwner, address NFTOwner);
    error UnknownInstance();

    modifier onlyInstance() {
        if (!whitelist.contains(msg.sender)) {
            revert InstancesOnly();
        }
        _;
    }

    constructor(address implementation) {
        require(implementation != address(0), "ZERO ADDRESS");
        implementationNFTSale = implementation;
    }

    ////////////////////////////////////////////////////////////////////////
    // external section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    
    /**
    * @notice mint distribute NFTs
    * @param tokenIds array of tokens that would be a minted
    * @param addresses array of desired owners to newly minted NFT tokens
    * @custom:calledby instance
    * @custom:shortd mint distribute NFTs
    */
    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external
        onlyInstance
    {
        
        address NFTcontract = instancesInfo[msg.sender].NFTContract;

        // get current owner directly from NFT instance contract
        address owner = Ownable(NFTcontract).owner();
        
        bool transferSuccess;
        bytes memory returndata;

        // factory is a trusted forwarder for NFT contract and calls makes as an owner
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
    * @notice view NFT contrac address. used by instances in external calls
    * @custom:calledby instance
    * @custom:shortd view NFT contrac address 
    */
    function getInstanceNFTcontract(
    ) 
        onlyInstance
        external 
        view 
        returns(address) 
    {
        return instancesInfo[msg.sender].NFTContract;
    }

    function whitelistByNFT(address NFTContract) external view returns(address[] memory instances) {
        uint256 len;
        address iAddr;
        uint256 j;
        for (uint256 i =0; i < whitelist.length(); i++) {
            iAddr = whitelist.at(i);
            if (instancesInfo[iAddr].NFTContract == NFTContract) {
                len++;
            }
        }

        instances = new address[](len);
        
        for (uint256 i =0; i < whitelist.length(); i++) {
            iAddr = whitelist.at(i);
            if (instancesInfo[iAddr].NFTContract == NFTContract) {
                instances[j] = iAddr;
                j++;
            }
        }
    }

    
    /**
    * @notice create NFTSales instance
    * @param NFTContract NFTcontract's address that allows to mintAndDistribute for this factory 
    * @param owner owner's adddress for newly created NFTSales contract
    * @param currency currency for every sale NFT token 
    * @param price price amount for every sale NFT token 
    * @param beneficiary address where which receive funds after sale
    * @param duration locked time when NFT will be locked after sale
    * @return instance address of created instance `NFTSales`
    * @custom:calledby owner
    * @custom:shortd creation NFTSales instance
    */
    function produce(
        address NFTContract,
        address owner, 
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) 
        public 
        returns (address instance) 
    {
        // get current owner directly from NFT instance contract
        address NFTOwner = Ownable(NFTContract).owner();
        if (NFTOwner != msg.sender) {
            revert OwnerOfNFTContractOnly(NFTContract, NFTOwner);
        }

        instance = address(implementationNFTSale).clone();

        _produce(instance, owner, NFTContract, currency, price, beneficiary, duration);

        INFTSales(instance).initialize(currency, price, beneficiary, duration);

        Ownable(instance).transferOwnership(owner);
    }

    /**
    * @notice remove ability to mintAndDistibute NFT tokens for certain instance
    * @param instance instance's address that would be added to blacklist and prevent call mintAndDistibute
    * @custom:calledby owner
    * @custom:shortd adding instance to black list
    */
    function removeFromWhiteList(address instance) public {
        address NFTContract = instancesInfo[instance].NFTContract;
        if (NFTContract == address(0)) {
            revert UnknownInstance();
        }
        address NFTOwner = Ownable(NFTContract).owner();
        if (NFTOwner != msg.sender) {
            revert OwnerOfNFTContractOnly(NFTContract, NFTOwner);
        }
        whitelist.remove(instance);
    }

    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

   
    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    function _produce(
        address instance,
        address owner, 
        address NFTContract,
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) 
        internal
    {
        require(instance != address(0), "NFTSalesFactory: INSTANCE_CREATION_FAILED");

        whitelist.add(instance);

        instancesInfo[instance] = InstanceInfo(NFTContract, owner, currency, price, beneficiary, duration);
        
        emit InstanceCreated(instance);
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