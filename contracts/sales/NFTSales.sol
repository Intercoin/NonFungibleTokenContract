// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./INFTSalesFactory.sol";
import "./INFTSales.sol";
import "./INFT.sol";
import "../whitelist/WhitelistUpgradeable.sol";

contract NFTSales is OwnableUpgradeable, WhitelistUpgradeable, INFTSales, IERC721ReceiverUpgradeable {

    using StringsUpgradeable for uint256;

    address currency;
    uint256 price;
    address beneficiary;
    uint64 duration;

    address factoryAddress;
    
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
        factoryAddress = owner();

        __Whitelist_init();

        __NFTSales_init(_currency, _price, _beneficiary, _duration);

    }


    /********************************************************************
    ****** external section *********************************************
    *********************************************************************/

    function specialPurchase(
        uint256[] memory tokenIds, 
        address[] memory addresses
    ) 
        external
        payable
        onlyWhitelist(commonGroupName)
    {
        address buyer = _msgSender();
        
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
        require(
            locked[tokenId].owner != address(0), 
            "unknown tokenId"
        );
        return remainingLockedTime(tokenId)/86400;
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

    /********************************************************************
    ****** public section ***********************************************
    *********************************************************************/
    /**
     * Adding addresses list to whitelist 
     * 
     * Requirements:
     *
     * - `_addresses` cannot contains the zero address.
     * 
     * @param _addresses list of addresses which will be added to whitelist
     */
    function whitelistAdd(
        address[] memory _addresses
    ) 
        public 
        onlyOwner
    {
        _whitelistAdd(commonGroupName, _addresses);
    }
    
    /**
     * Removing addresses list from whitelist
     * 
     * Requirements:
     *
     * - `_addresses` cannot contains the zero address.
     * 
     * @param _addresses list of addresses which will be removed from whitelist
     */
    function whitelistRemove(
        address[] memory _addresses
    ) 
        onlyOwner
        public 
    {
        _whitelistRemove(commonGroupName, _addresses);
    }

    /**
    * Checks if a address already exists in a whitelist
    * 
    * @param addr address
    * @return result return true if exist 
    */
    function isWhitelisted(address addr) public virtual view returns (bool result) {
        result = _isWhitelisted(commonGroupName, addr);
    }
    
    
    /********************************************************************
    ****** internal section *********************************************
    *********************************************************************/
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

    function getBlockTimestamp() public view returns(uint256) {
        return block.timestamp;
    }

    function _claim(
        uint256[] memory tokenIds,
        bool shouldCheckOwner
    ) 
        internal
    {
        address NFTcontract = INFTSalesFactory(getFactory()).getInstanceNFTcontract();
        for(uint256 i=0; i<tokenIds.length; i++) {

            require(
                locked[tokenIds[i]].owner != address(0), 
                "unknown tokenId"
            );

            require(
                locked[tokenIds[i]].untilTimestamp < uint64(block.timestamp), 
                string(abi.encodePacked(
                    "Tokens can be claimed after ", 
                    uint256(remainingLockedTime(tokenIds[i])/86400).toString(),
                    " more days."
                ))
            );

            require(
                (shouldCheckOwner == false) ||
                (
                    shouldCheckOwner == true && 
                    locked[tokenIds[i]].owner == _msgSender()
                ),
                "should be owner"
            );

            IERC721Upgradeable(NFTcontract).safeTransferFrom(address(this), locked[tokenIds[i]].owner, tokenIds[i]);

            delete locked[tokenIds[i]];
        }
    }

    function getFactory() internal view returns(address) {
        return factoryAddress; // deployer of contract. this can't make sense if deployed manually
    }

    function remainingLockedTime(
        uint256 tokenId
    )
        internal 
        view
        returns(uint64)
    {
        return locked[tokenId].untilTimestamp > uint64(block.timestamp) ? locked[tokenId].untilTimestamp - uint64(block.timestamp) : 0;
    }
}