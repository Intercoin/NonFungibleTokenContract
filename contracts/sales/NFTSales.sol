// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./INFTSalesFactory.sol";
import "./INFTSales.sol";
import "./INFT.sol";

contract NFTSales is OwnableUpgradeable, INFTSales, IERC721ReceiverUpgradeable {

//    using StringsUpgradeable for uint256;

    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64

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

    mapping(address => bool) specialPurchasesList;

    struct AutoMintStruct {
        uint256 index;
        mapping(address => bool) list;
    }
    mapping(uint64 => AutoMintStruct) autoMint;

    error StillLocked(uint64 daysLeft, uint64 secondsLeft);
    error InvalidAddress(address addr);
    error InsufficientFunds(uint256 expected, uint256 sent);
    error UnknownTokenIdForClaim(uint256 tokenId);
    error TransferCommissionFailed();
    error RefundFailed();
    error ShouldBeTokenOwner(address account);
    error NotInWhiteList(address account);
    error NotInListForAutoMint(address account, uint64 seriesId);

    function getSeriesId(
        uint256 tokenId
    )
        internal
        pure
        returns(uint64)
    {
        return uint64(tokenId >> SERIES_SHIFT_BITS);
    }


    /**
    * @notice initialization 
    * @param _currency currency for every sale nft token 
    * @param _price price amount for every sale nft token 
    * @param _beneficiary address where which receive funds after sale
    * @param _duration locked time when nft will be locked after sale
    * @custom:calledby factory on initialization
    * @custom:shortd initialization instance
    */
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

        __NFTSales_init(_currency, _price, _beneficiary, _duration);

    }


    /********************************************************************
    ****** external section *********************************************
    *********************************************************************/
    /**
    * @notice sell NFT tokens
    * @param tokenIds array of tokens that would be a sold
    * @param addresses array of desired owners to newly sold nft tokens
    * @custom:calledby person in the whitelist
    * @custom:shortd sell NFT tokens
    */
    function specialPurchase(
        uint256[] memory tokenIds, 
        address[] memory addresses
    ) 
        external
        payable
    {
        address buyer = _msgSender();

        if (!specialPurchasesList[buyer]) {
            revert NotInWhiteList(buyer);
        }
        
        require(tokenIds.length != 0 && tokenIds.length == addresses.length);

        uint256 totalPrice = (price)*(tokenIds.length);
        // for(uint256 i = 0; i<tokenIds.length; i++) {
        //     totalPrice = saleInfo.autoincrement+i;
        // }
        _confirmPay(totalPrice, buyer);
        _distributeTokens(tokenIds, addresses);
        
    }

    
    function autorizeMintAndDistributeAuto(uint64 seriesID, address account, uint256 amount) external {
        address buyer = _msgSender();

        if (!autoMint[seriesID].list[buyer]) {
            revert NotInListForAutoMint(buyer, seriesID);
        }
        
        require(amount != 0);
        
        //uint256 tokenId = tokenIds[0];
        //uint64 seriesId = uint64(tokenId >> 192);//getSeriesId(tokenId);


        uint256 totalPrice = (price)*(amount);
        // for(uint256 i = 0; i<tokenIds.length; i++) {
        //     totalPrice = saleInfo.autoincrement+i;
        // }
        
        // confirm pay
        _confirmPay(totalPrice, buyer);
       
        address[] memory addresses = new address[](amount);
        for(uint256 i=0; i<amount; i++) {
            addresses[i] = account;
        }

        // generate token ids
        uint256[] memory tokenIds = _getTokenIds(seriesID, amount);

        _distributeTokens(tokenIds, addresses);

    }

    function _getTokenIds(uint64 seriesId, uint256 amount) internal returns(uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](amount);

        // TODO 0: 
        // generate tokenids via autoindex,
        // increament autoidnex
        // check if tokenid in loop dos not have owner  

        // generate tokenIDS here
        
        return tokenIds;
    }

    function _distributeTokens(uint256[] memory tokenIds, address[] memory addresses) internal {
        // distribute tokens
        if (duration == 0) {
            INFTSalesFactory(factoryAddress).mintAndDistribute(tokenIds, addresses);
        } else {

            address[] memory selfAddresses = new address[](tokenIds.length);
            for(uint256 i=0; i<tokenIds.length; i++) {
                selfAddresses[i] = address(this);

                locked[tokenIds[i]] = TokenData(addresses[i], duration + uint64(block.timestamp));
            }


            INFTSalesFactory(factoryAddress).mintAndDistribute(tokenIds, selfAddresses);

        }
    }

    function _confirmPay(
        uint256 totalPrice,
        address buyer
    ) internal {
        
        bool transferSuccess;

        if (currency == address(0)) {
            if (msg.value < totalPrice) {
                revert InsufficientFunds(totalPrice, msg.value);
            }

            (transferSuccess, ) = (beneficiary).call{gas: 3000, value: (totalPrice)}(new bytes(0));
            if (!transferSuccess) { revert TransferCommissionFailed(); }
            
            uint256 refundAmount = msg.value - totalPrice;
            if (refundAmount > 0) { // or maybe need a minimal value when refund triggered?
                (transferSuccess, ) = (buyer).call{gas: 3000, value: (refundAmount)}(new bytes(0));
                if (!transferSuccess) { revert RefundFailed(); }
            }
        } else {
            IERC20Upgradeable(currency).transferFrom(buyer, beneficiary, totalPrice);
        }
    }


    /**
    * @notice amount of days+1 that left to unlocked
    * @return amount of days+1 that left to unlocked
    * @custom:calledby person in the whitelist
    * @custom:shortd locked days
    */
    function remainingDays(
        uint256 tokenId
    ) 
        external 
        view 
        returns(uint64) 
    {
        _validateTokenId(tokenId);
        
        return _remainingDays(tokenId);
    }

    
    /**
    * @notice distribute unlocked tokens
    * @param tokenIds array of tokens that need to be unlocked
    * @custom:calledby everyone
    * @custom:shortd claim locked tokens
    */
    function distributeUnlockedTokens(
        uint256[] memory tokenIds
    ) 
        external 
    {
        _claim(tokenIds, false);
    }

    /**
    * @notice claim unlocked tokens
    * @param tokenIds array of tokens that need to be unlocked
    * @custom:calledby owner of tokenIds
    * @custom:shortd claim locked tokens
    */
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

    /**
     * Adding addresses list to whitelist (specialPurchasesList)
     * 
     * Requirements:
     *
     * - `addresses` cannot contains the zero address.
     * 
     * @param addresses list of addresses which will be added to specialPurchasesList
     */
    function specialPurchasesListAdd(address[] memory addresses) external onlyOwner {
        _whitelistManage(specialPurchasesList, addresses, true);
    }
    
    /**
     * Removing addresses list from whitelist (specialPurchasesList)
     * 
     * Requirements:
     *
     * - `addresses` cannot contains the zero address.
     * 
     * @param addresses list of addresses which will be removed from specialPurchasesList
     */
    function specialPurchasesListRemove(address[] memory addresses) external onlyOwner {
        _whitelistManage(specialPurchasesList, addresses, false);
    }

    function mintWhitelistAdd(uint64 seriesID, address[] memory addresses) external onlyOwner {
        _whitelistManage(autoMint[seriesID].list, addresses, true);
    }

    function mintWhitelistRemove(uint64 seriesID, address[] memory addresses) external onlyOwner {
        _whitelistManage(autoMint[seriesID].list, addresses, false);
    }

    function setAutoIndex(uint64 seriesID, uint256 index) external onlyOwner {
        autoMint[seriesID].index = index;
    }

    /********************************************************************
    ****** public section ***********************************************
    *********************************************************************/
    



    /********************************************************************
    ****** internal section *********************************************
    *********************************************************************/
    
    function _whitelistManage(mapping(address => bool) storage list, address[] memory addresses, bool state) internal {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == address(0)) {
                revert InvalidAddress(addresses[i]);
            }
            list[addresses[i]] = state;
        }
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

    function _claim(
        uint256[] memory tokenIds,
        bool shouldCheckOwner
    ) 
        internal
    {
        address NFTcontract = INFTSalesFactory(getFactory()).getInstanceNFTcontract();
        for(uint256 i=0; i<tokenIds.length; i++) {

            _checkTokenForClaim(tokenIds[i], shouldCheckOwner);
            
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

    /**
    * @notice it's internal method. Expect that token id exists. means `locked[tokenId].owner != address(0)`
    * @param tokenId token id
    * @return days that left to unlock  plus one day
    */
    function _remainingDays(
        uint256 tokenId
    ) 
        internal
        view 
        returns(uint64) 
    {
        
        return (remainingLockedTime(tokenId)/86400) + 1;
    }

    function _validateTokenId(uint256 tokenId) internal view {
        if (locked[tokenId].owner == address(0)) {
            revert UnknownTokenIdForClaim(tokenId);
        }
    }

    function _checkTokenForClaim(uint256 tokenId, bool shouldCheckOwner) internal view {
        _validateTokenId(tokenId);

        if (locked[tokenId].untilTimestamp >= uint64(block.timestamp)) {
            revert StillLocked(_remainingDays(tokenId), remainingLockedTime(tokenId));
        }

        // if !(
        //     (shouldCheckOwner == false) ||
        //     (
        //         shouldCheckOwner == true && 
        //         locked[tokenId].owner == _msgSender()
        //     )
        // ) {
        //      revert ShouldBeOwner(_msgSender());
        // }

        if (
            (shouldCheckOwner) &&
            (
                !shouldCheckOwner || 
                locked[tokenId].owner != _msgSender()
            )
        ) {
            revert ShouldBeTokenOwner(_msgSender());
        }
        
    }

}