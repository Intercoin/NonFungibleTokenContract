// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./INFTSales.sol";
import "./INFTSalesFactory.sol";
import "./INFT.sol";

contract NFTSalesFactory is Ownable, INFTSalesFactory {
    using Clones for address;
    using EnumerableSet for EnumerableSet.AddressSet;

     /**
    * @custom:shortd Community implementation address
    * @notice Community implementation address
    */
    address public immutable implementationNftSale;

    EnumerableSet.AddressSet internal instances;
    EnumerableSet.AddressSet internal blackList;
    
    struct InstanceInfo {
        address nftAddress;        
        address owner;
        address currency;
        uint256 price;
        address beneficiary;
        uint64 duration;
    }
    mapping(address =>InstanceInfo) instancesInfo;

    event InstanceCreated(address instance, uint instancesCount);

    modifier onlyInstance() {
        require(instances.contains(_msgSender()), "instances only");
        require(!blackList.contains(_msgSender()), "instance in black list");
        _;
    }
    /**
    */
    constructor(
        address implementation
    ) {
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
        amount = instances.length();
    }

    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external
        onlyInstance
    {
        //address instance = _msgSender();
        //address nftAddress = instancesInfo[instance].nftAddress;
        address nftAddress = instancesInfo[_msgSender()].nftAddress;

        // get current owner directly from nft instance contract
        address owner = Ownable(nftAddress).owner();
        
        bool transferSuccess;
        bytes memory returndata;

        // factory is a trusted forwarder for nft contract and calls makes as an owner
        (transferSuccess, returndata) = nftAddress.call(
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

    function getInstanceNftAddress(
    ) 
        onlyInstance
        external 
        view 
        returns(address) 
    {
        return instancesInfo[_msgSender()].nftAddress;
    }


    ////////////////////////////////////////////////////////////////////////
    // public section //////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    /**
    * param hook address of contract implemented ICommunityHook interface. Can be address(0)
    * param name erc721 name
    * param symbol erc721 symbol
    * @return instance address of created instance `CommunityERC721`
    * @custom:shortd creation CommunityERC721 instance
    */
    function produce(
        address nftAddress,
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

        _produce(instance, owner, nftAddress, currency, price, beneficiary, duration);
        
        INFTSales(instance).initialize(currency, price, beneficiary, duration);

        Ownable(instance).transferOwnership(owner);
        
        _postProduce(instance);
        
    }

    ////////////////////////////////////////////////////////////////////////
    // internal section ////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////

    function _produce(
        address instance,
        address owner, 
        address nftAddress,
        address currency, 
        uint256 price, 
        address beneficiary, 
        uint64 duration
    ) 
        internal
    {
        require(instance != address(0), "NFTSalesFactory: INSTANCE_CREATION_FAILED");

        instances.add(instance);

        instancesInfo[instance] = InstanceInfo(nftAddress, owner, currency, price, beneficiary, duration);
        // instancesInfo[instance] = InstanceInfo({
        //     nftAddress: nftAddress,
        //     owner: owner,
        //     currency: currency,
        //     price: price,
        //     beneficiary: beneficiary,
        //     duration: duration
        // });
        
        emit InstanceCreated(instance, instances.length());
    }

     function _postProduce(
        address instance
    ) 
        internal
    {
        // address[] memory s = new address[](1);
        // s[0] = msg.sender;

        // uint8[] memory r = new uint8[](1);
        // r[0] = 2;//"owners";

        // //ICommunityTransfer(instance).addMembers(s);
        // ICommunityTransfer(instance).grantRoles(s, r);

    }

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