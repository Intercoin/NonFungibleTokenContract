// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./INFTSalesFactory.sol";
import "./INFTSales.sol";
import "./INFT.sol";

contract NFTSales is OwnableUpgradeable, INFTSales, IERC721ReceiverUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint192 internal constant MAX_TOKEN_INDEX = type(uint192).max;

    address public currency;
    uint64 public seriesId;
    uint256 public price;
    address public beneficiary;
    uint64 public duration;
    uint32 public rateInterval;
    uint192 public currentAutoIndex;
    uint16 public rateAmount;
    bool public evenIfNotOnSale;

    address public factoryAddress;

    uint256 internal seriesPart;

    struct TokenData {
        address owner;
        uint64 untilTimestamp;
    }
    
    mapping(uint256 => uint256) purchaseBucket;

    mapping(uint256 => TokenData) locked;

    EnumerableSetUpgradeable.AddressSet specialPurchasesList;

    error StillLocked(uint64 daysLeft, uint64 secondsLeft);
    error InvalidAddress(address addr);
    error InsufficientFunds(address currency, uint256 expected, uint256 sent);
    error UnknownTokenIdForClaim(uint256 tokenId);
    error TransferCommissionFailed();
    error RefundFailed();
    error ShouldBeTokenOwner(address account);
    error NotInWhiteList(address account);
    error NotInListForAutoMint(address account, uint64 seriesId);
    error SeriesMaxTokenLimitExceeded(uint64 seriesId);
    error TooMuchBoughtInCurrentInterval(uint256 currentInterval, uint256 willBeBought, uint32 maxAmount);
    error SeriesIsNotOnSale(uint64 seriesId);
    error IncorrectInputParameters();

    /**
     * @notice initialization
     * @param _currency currency for every sale NFT token
     * @param _price price amount for every sale NFT token
     * @param _beneficiary address where which receive funds after sale
     * @param _autoindex from what index contract will start autoincrement from each series(if owner doesnot set before) 
     * @param _duration locked time when NFT will be locked after sale
     * @param _rateInterval interval in which contract should sell not more than `_rateAmount` tokens
     * @param _rateAmount amount of tokens that can be minted in each `_rateInterval`
     * @custom:calledby factory on initialization
     * @custom:shortd initialization instance
     */
    function initialize(
        uint64 _seriesId,
        address _currency,
        uint256 _price,
        address _beneficiary,
        uint192 _autoindex,
        uint64 _duration,
        uint32 _rateInterval,
        uint16 _rateAmount
    )
        external
        //override
        initializer
    {
        __Ownable_init();
        __ReentrancyGuard_init();

        factoryAddress = owner();

        __NFTSales_init(_seriesId, _currency, _price, _beneficiary, _autoindex, _duration, _rateInterval, _rateAmount);

        
    }

    /********************************************************************
     ****** external section *********************************************
     *********************************************************************/
    /**
     * @notice sell NFT tokens
     * param tokenIds array of tokens that would be a sold
     * param addresses array of desired owners to newly sold NFT tokens
     * @custom:calledby person in the whitelist
     * @custom:shortd sell NFT tokens
     */
    function specialPurchase(
        address account,
        uint256 amount
    ) external payable nonReentrant {
        address buyer = _msgSender();

        if (!specialPurchasesList.contains(buyer)) {
            revert NotInWhiteList(buyer);
        }

        _purchase(account, amount, buyer, true);
    }

    function purchase(
        address account,
        uint256 amount
    ) external payable nonReentrant {
        address buyer = _msgSender();
        _purchase(account, amount, buyer, false);
    }

    /**
     * @notice amount of days+1 that left to unlocked
     * @return amount of days+1 that left to unlocked
     * @custom:calledby person in the whitelist
     * @custom:shortd locked days
     */
    function remainingDays(uint256 tokenId) external view returns (uint64) {
        _validateTokenId(tokenId);
        return _remainingDays(tokenId);
    }

    /**
     * @notice distribute unlocked tokens
     * @param tokenIds array of tokens that need to be unlocked
     * @custom:calledby everyone
     * @custom:shortd claim locked tokens
     */
    function distributeUnlockedTokens(uint256[] memory tokenIds) external {
        _claim(tokenIds, false);
    }

    /**
     * @notice claim unlocked tokens
     * @param tokenIds array of tokens that need to be unlocked
     * @custom:calledby owner of tokenIds
     * @custom:shortd claim locked tokens
     */
    function claim(uint256[] memory tokenIds) external {
        _claim(tokenIds, true);
    }

    function onERC721Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*tokenId*/
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

    /**
     * @param index index from what will be autogenerated tokenid for seriesId
     */
    function setAutoIndex(uint192 index) external onlyOwner {
        currentAutoIndex = index;
    }

    /**
     * Checking Is account in common whitelist
     * @param account address
     * @return true if account in the whitelist. otherwise - no
     */
    function isWhitelisted(address account) external view returns (bool) {
        return specialPurchasesList.contains(account);
    }

    /**
    * @param flag if true that user can mint tokens through `specialpurchase` even if series in not on salse
    */
    function setEvenIfNotOnSale(bool flag) external onlyOwner {
        evenIfNotOnSale = flag;
    }

    /**
    * getting array of whitelisted addresses. used by frontend. return all addresses
    */
    function whitelisted() external view returns(address[] memory ret) {
        uint256 len = specialPurchasesList.length();
        ret = new address[](len);
        for (uint256 i = 0; i<len; i++) {
           ret[i] = specialPurchasesList.at(i);
        }
    }

    /**
    * getting array of whitelisted addresses. overloaded. used by frontend. supports pagination
    * @param page number of page
    * @param count amount of addresess of page number
    * @return ret array of whitelisted addresses
    * note that 
    *   if there are no any addresses on the page - method will return zero array
    *   if addresses exists but their amounts less than `count` - returns array will be without zero values and size will be less
    *   else returns array will be with length equal `count`
    */
    function whitelisted(uint256 page, uint256 count) external view returns(address[] memory ret) {
        if (page == 0 || count == 0) {
            revert IncorrectInputParameters();
        }

        uint256 len = specialPurchasesList.length();
        uint256 ifrom = page*count-count;

        if (
            len == 0 || 
            ifrom >= len
        ) {
            ret = new address[](0);
        } else {

            count = ifrom+count > len ? len-ifrom : count ;
            ret = new address[](count);

            for (uint256 i = ifrom; i<ifrom+count; i++) {
                ret[i-ifrom] = specialPurchasesList.at(i);
                
            }
        }

        
    }
    

    /********************************************************************
     ****** public section ***********************************************
     *********************************************************************/
    /**
    * @return amount addresses from the special purchases list
    */
    function whitelistedCount() external view returns(uint256) {
        return specialPurchasesList.length();
    }
    /********************************************************************
     ****** internal section *********************************************
     *********************************************************************/
    
    function _purchase(
        address account,
        uint256 amount,
        address buyer,
        bool isSpecialPurchase
    ) internal {

        require(amount != 0);

        if (isSpecialPurchase) {
            uint256 currentInterval = currentBucketInterval();
            purchaseBucket[currentInterval] += amount;
            if (purchaseBucket[currentInterval] > rateAmount) {
                revert TooMuchBoughtInCurrentInterval(currentInterval, purchaseBucket[currentInterval], rateAmount);
            }
        }
        // generate token ids
        (uint256[] memory tokenIds, address currencyAddr, uint256 currencyTotalPrice, uint192 lastIndex) = _getTokenIds(amount, isSpecialPurchase);
        currentAutoIndex = lastIndex + 1;
        
        // confirm pay
        _confirmPay(currencyTotalPrice, currencyAddr, buyer);

        _distributeTokens(tokenIds, account);
    }

    function _distributeTokens(uint256[] memory tokenIds, address account) internal {
        
        address[] memory addresses = new address[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            addresses[i] = account;
        }

        // distribute tokens
        if (duration == 0) {
            INFTSalesFactory(factoryAddress)._doMintAndDistribute(tokenIds, addresses);
        } else {
            address[] memory selfAddresses = new address[](tokenIds.length);
            for (uint256 i = 0; i < tokenIds.length; i++) {
                selfAddresses[i] = address(this);

                locked[tokenIds[i]] = TokenData(addresses[i], duration + uint64(block.timestamp));
            }

            INFTSalesFactory(factoryAddress)._doMintAndDistribute(tokenIds, selfAddresses);
        }
    }

    function _confirmPay(uint256 totalPrice, address currencyToPay, address buyer) internal {
        bool transferSuccess;

        if (currencyToPay == address(0)) {
            if (msg.value < totalPrice) {
                revert InsufficientFunds(currencyToPay, totalPrice, msg.value);
            }

            (transferSuccess, ) = (beneficiary).call{gas: 3000, value: (totalPrice)}(new bytes(0));
            if (!transferSuccess) {
                revert TransferCommissionFailed();
            }

            uint256 refundAmount = msg.value - totalPrice;
            if (refundAmount > 0) {
                // or maybe need a minimal value when refund triggered?
                (transferSuccess, ) = (buyer).call{gas: 3000, value: (refundAmount)}(new bytes(0));
                if (!transferSuccess) {
                    revert RefundFailed();
                }
            }
        } else {
            IERC20Upgradeable(currencyToPay).transferFrom(buyer, beneficiary, totalPrice);
        }
    }

    function _whitelistManage(
        EnumerableSetUpgradeable.AddressSet storage list,
        address[] memory addresses,
        bool state
    ) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            if (addresses[i] == address(0)) {
                revert InvalidAddress(addresses[i]);
            }
            if (state) {
                list.add(addresses[i]);
            } else {
                list.remove(addresses[i]);
            }
        }
    }

    function __NFTSales_init(
        uint64 _seriesId,
        address _currency,
        uint256 _price,
        address _beneficiary,
        uint192 _autoindex,
        uint64 _duration,
        uint32 _rateInterval,
        uint16 _rateAmount
    ) internal onlyInitializing {
        seriesId = _seriesId;
        currency = _currency;
        price = _price;
        beneficiary = _beneficiary;
        currentAutoIndex = _autoindex;
        duration = _duration;
        rateInterval = _rateInterval;
        rateAmount = _rateAmount;

        seriesPart = (uint256(seriesId) << SERIES_SHIFT_BITS);
    }

    function _claim(uint256[] memory tokenIds, bool shouldCheckOwner) internal nonReentrant {
        address NFTcontract = INFTSalesFactory(getFactory())._doGetInstanceNFTcontract();
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _checkTokenForClaim(tokenIds[i], shouldCheckOwner);

            IERC721Upgradeable(NFTcontract).safeTransferFrom(address(this), locked[tokenIds[i]].owner, tokenIds[i]);

            delete locked[tokenIds[i]];
        }
    }

    function getFactory() internal view returns (address) {
        return factoryAddress; // deployer of contract. this can't make sense if deployed manually
    }

    function remainingLockedTime(uint256 tokenId) internal view returns (uint64) {
        return
            locked[tokenId].untilTimestamp > uint64(block.timestamp)
                ? locked[tokenId].untilTimestamp - uint64(block.timestamp)
                : 0;
    }

    /**
     * @notice it's internal method. Expect that token id exists. means `locked[tokenId].owner != address(0)`
     * @param tokenId token id
     * @return days that left to unlock  plus one day
     */
    function _remainingDays(uint256 tokenId) internal view returns (uint64) {
        return (remainingLockedTime(tokenId) / 86400) + 1;
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

        if ((shouldCheckOwner) && (!shouldCheckOwner || locked[tokenId].owner != _msgSender())) {
            revert ShouldBeTokenOwner(_msgSender());
        }
    }

    /**
     * for special purchase get getTokenSaleInfo externally to get currency and token separately for each token
     */
    function _getTokenIds(
        uint256 amount, 
        bool isSpecialPurchase
    ) 
        internal 
        view 
        returns (
            uint256[] memory tokenIds, 
            address currencyAddr, 
            uint256 currencyTotalPrice, 
            uint192 lastIndex
        ) 
    {
        tokenIds = new uint256[](amount);

        uint256 amountLeft = amount;

        uint256 tokenId;

        lastIndex = currentAutoIndex;


        address NFTContract = INFTSalesFactory(factoryAddress)._doGetInstanceNFTcontract();

        // Is this whole series for sale?
        //INFT.SeriesInfo memory seriesData = INFT(NFTContract).seriesInfo(seriesId);
        // bool isSeriesOnSale = (seriesData.saleInfo.onSaleUntil > block.timestamp);
        INFT.SaleInfo memory saleInfo;
        (, , saleInfo, , , ) = INFT(NFTContract).seriesInfo(seriesId);
        bool isSeriesOnSale = (saleInfo.onSaleUntil > block.timestamp);
        //console.log(seriesData.saleInfo.onSaleUntil);
        

        if (
            (!isSpecialPurchase && !isSeriesOnSale) ||
            (isSpecialPurchase && !isSeriesOnSale && !evenIfNotOnSale)
        ) {
            revert SeriesIsNotOnSale(seriesId);
        }

        while (lastIndex != MAX_TOKEN_INDEX) {

            tokenId = seriesPart + lastIndex;

            //exists means that  _owners[tokenId] != address(0) && _owners[tokenId] != DEAD_ADDRESS;
            (/*bool isOnSale*/, bool exists, INFT.SaleInfo memory data, /*address beneficiary*/) = INFT(NFTContract).getTokenSaleInfo(tokenId);

            if (!exists) {
                // !exists - means only virtuals

                // for usual purchase:
                // - increment total price
                // for special purchase - move out of cycle and just calcualte amount*price(stored in contract)
                if (!isSpecialPurchase) {
                    currencyTotalPrice += data.price;
                }
                
                amountLeft--;
                tokenIds[amountLeft] = tokenId; // did it slightly cheaper and do fill from "N-1" to "0" and avoid "stack too deep" error

            }
            if (amountLeft == 0) {
                break;
            }
            lastIndex++;
        }

        if (isSpecialPurchase) {
            currencyAddr = currency;
            currencyTotalPrice = amount * price;
        } else {
            //currencyAddr = seriesData.saleInfo.currency;
            currencyAddr = saleInfo.currency;
            //currencyTotalPrice calculated inside cycle
        }

        if (lastIndex == MAX_TOKEN_INDEX || amountLeft != 0) {
            revert SeriesMaxTokenLimitExceeded(seriesId);
        }

    }

    function getSeriesId(uint256 tokenId) internal pure returns (uint64) {
        return uint64(tokenId >> SERIES_SHIFT_BITS);
    }

    function currentBucketInterval() internal view returns(uint256) {
        return block.timestamp / rateInterval * rateInterval;
    }
}
