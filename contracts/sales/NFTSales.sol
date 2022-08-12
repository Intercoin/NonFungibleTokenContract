// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./INFTSalesFactory.sol";
import "./INFTSales.sol";
import "./INFT.sol";

contract NFTSales is OwnableUpgradeable, INFTSales, IERC721ReceiverUpgradeable {

    address currency;
    uint256 price;
    address beneficiary;
    uint64 duration;
    
    struct TokenData {
         address owner;
         uint64 untilTimestamp;
    }
    
    mapping(uint256 => TokenData) locked;



    function initialize(
        address _currency, 
        uint256 _price, 
        address _beneficiary, 
        uint64 _duration
    ) 
        external
        //override
        initializer 
    {
        __Ownable_init();

        __NFTSales_init(_currency, _price, _beneficiary, _duration);


    }

    function __NFTSales_init(
        address _currency, 
        uint256 _price, 
        address _beneficiary, 
        uint64 _duration
    ) 
        internal 
        onlyInitializing
    {
        currency    = _currency;
        price       = _price;
        beneficiary = _beneficiary;
        duration    = _duration;
    }

    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    ) 
        external
        payable
    {
        address buyer = _msgSender();
        address factoryAddress = owner();

        require(tokenIds.length != 0 && tokenIds.length == addresses.length);
        
        //uint256 tokenId = tokenIds[0];
        //uint64 seriesId = uint64(tokenId >> 192);//getSeriesId(tokenId);

        bool transferSuccess;

        uint256 totalPrice = (price)*(tokenIds.length);
        // for(uint256 i = 0; i<tokenIds.length; i++) {
        //     totalPrice = saleInfo.autoincrement+i;
        // }

        // confirm pay
        if (currency == address(0)) {
            (transferSuccess, ) = (beneficiary).call{gas: 3000, value: (totalPrice)}(new bytes(0));
            require(transferSuccess, "TRANSFER_COMMISSION_FAILED");
        } else {
            IERC20Upgradeable(currency).transferFrom(buyer, beneficiary, totalPrice);
        }

        
        // distribute tokens
        if (duration == 0) {
            INFTSalesFactory(factoryAddress).mintAndDistribute(tokenIds, addresses);
        } else {

            address[] memory selfAddresses = new address[](tokenIds.length);
            for(uint256 i=0; i<tokenIds.length; i++) {
                selfAddresses[i] = address(this);

                locked[tokenIds[i]] = TokenData(buyer, duration + uint64(block.timestamp));
            }


            INFTSalesFactory(factoryAddress).mintAndDistribute(tokenIds, selfAddresses);

        }
        

    }

    //simply return "how many days left to unlocked"
    function remainingDays(
        uint256 tokenId
    ) 
        external 
        view 
        returns(uint64) 
    {
        return locked[tokenId].untilTimestamp > uint64(block.timestamp) ? locked[tokenId].untilTimestamp - uint64(block.timestamp) : 0;
    }

    // distribute unlocked tokens to the appropriate addresses
    // called by any user
    function distributeUnlockedTokens(
        uint256[] memory tokenIds
    ) 
        external 
    {
        _claim(tokenIds, false);
    }

    function claim(
        uint256[] memory tokenIds
    ) 
        external 
    {
        _claim(tokenIds, true);
    }

    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    function _claim(
        uint256[] memory tokenIds,
        bool shouldCheckOwner
    ) 
        internal
    {
        address nftAddress = INFTSalesFactory(getFactory()).getInstanceNftAddress();
        for(uint256 i=0; i<tokenIds.length; i++) {
            require(
                locked[tokenIds[i]].owner != address(0), 
                "unknown tokenId"
            );
            require(
                locked[tokenIds[i]].untilTimestamp <= uint64(block.timestamp), 
                "still locked"
            );
            require(
                (shouldCheckOwner == false) ||
                (
                    shouldCheckOwner == true && 
                    locked[tokenIds[i]].owner == _msgSender()
                ),
                "should be owner"
            );

            IERC721Upgradeable(nftAddress).safeTransferFrom(address(this), locked[tokenIds[i]].owner, tokenIds[i]);

            delete locked[tokenIds[i]];
        }
    }

    function getFactory() internal view returns(address) {
        return owner(); // deployer of contract. this can't make sense if factory some how will make transferownership
    }
}