// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSeriesBase.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract NFTSeries is NFTSeriesBase, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using LibCommunity for LibCommunity.Settings;
    
    LibCommunity.Settings internal communitySettings;

    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    event TokenRemovedFromSale(uint256 tokenId);
    event TokensAddedToSale(uint256 tokenIdFrom, uint256 tokenIdTo, uint256 amount, address consumeToken);
    
    modifier canRecord(string memory communityRole) {
        require(communitySettings._canRecord(communityRole) == true, "Sender has not in accessible List");
        _;
    }
    
    function initialize(
        string memory name,
        string memory symbol,
        LibCommunity.Settings memory communitySettings_
    ) 
        public 
        override 
        initializer 
    {
        communitySettings = communitySettings_;
        __Ownable_init();
        __ReentrancyGuard_init();
        __ERC721Series_init(name, symbol);
    }
    
    function create(
        string memory URI,
        CommissionParams memory commissionParams,
        uint256 tokenAmount
    ) 
        public 
        virtual  
    {
        _create(URI, commissionParams, tokenAmount);

    }
    
    /**
     * creation NFT token and immediately put to list for sale
     * @param URI Token URI
     * @param commissionParams commission will be send to author when token's owner sell to someone it. See {INFT-CommissionParams}.
     * @param tokenAmount amount of created tokens
     * @param consumeAmount amount that need to be paid to owner when some1 buy token
     * @param consumeToken erc20 token. if set address(0) then expected coins to pay for NFT
     */
    function createAndSale(
        string memory URI,
        CommissionParams memory commissionParams,
        uint256 tokenAmount,
        uint256 consumeAmount,
        address consumeToken
    ) 
        public 
        virtual  
    {
        (, uint256 rangeId) = _create(URI, commissionParams, tokenAmount);
        
        _listForSale(rangeId, consumeAmount, consumeToken);
        
        emit TokensAddedToSale(ranges[rangeId].from, ranges[rangeId].to, consumeAmount, consumeToken);
        
    }
    
    /** 
     * returned commission that will be paid to token's author while transferring NFT
     * @param tokenId NFT tokenId
     */
    function getCommission(
        uint256 tokenId
    ) 
        public
        view
        returns(address t, uint256 r)
    {
        (, uint256 rangeId, ) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        
        (t, r) = _getCommission(tokenId);
    }
    
    /**
     * contract's owner can claim tokens mistekenly sent to this contract
     * @param erc20address ERC20 address contract
     */
    function claimLostToken(
        address erc20address
    ) 
        public 
        onlyOwner 
    {
        uint256 funds = IERC20Upgradeable(erc20address).balanceOf(address(this));
        require(funds > 0, "There are no lost tokens");
            
        bool success = IERC20Upgradeable(erc20address).transfer(_msgSender(), funds);
        //require(success, "Failed when 'transferFrom' funds");
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
        require(success);
    }
    
    /**
     * put NFT to list for sale. then anyone can buy it
     * @param tokenId NFT tokenId
     * @param amount amount that need to be paid to owner when some1 buy token
     * @param consumeToken erc20 token. if set address(0) then expected coins to pay for NFT
     */
    function listForSale(
        uint256 tokenId,
        uint256 amount,
        address consumeToken
    )
        public
    {
        uint256 rangeId = _preListForSale(tokenId);
        
        _postListForSale(rangeId, tokenId, amount, consumeToken);
        
    }
    
    
    /**
     * remove NFT from list for sale.
     * @param tokenId NFT tokenId
     */
    function removeFromSale(
        uint256 tokenId
    )
        public 
    {
        (uint256 serieId, uint256 rangeId, ) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        _validateTokenOwner(rangeId);
        
        (, uint256 newRangeId) = __splitSeries(serieId, rangeId, tokenId);
        
        ranges[newRangeId].saleData.isSale = false;    

        emit TokenRemovedFromSale(tokenId);
    }
    
    /**
     * sale info
     * @param tokenId NFT tokenId
     * @return address consumeToken
     * @return uint256 amount
     */
    function saleInfo(
        uint256 tokenId
    )   
        public
        view
        returns(address, uint256)
    {
        (, uint256 rangeId, ) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        _validateOnlySale(rangeId);
        
        return (ranges[rangeId].saleData.erc20Address, ranges[rangeId].saleData.amount);
    }
    
    /**
     * buying token. new owner need to pay for nft by coins. Also payment to author is expected
     * @param tokenId NFT tokenId
     */
    function buy(
        uint256 tokenId
    )
        public 
        payable
        nonReentrant
    {
        (, uint256 rangeId, bool isSingle) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        _validateOnlySale(rangeId);
        _validateOnlySaleForCoins(rangeId);
        if (!isSingle) {
            (, rangeId) = splitSeries(tokenId);
        }

        bool success;
        uint256 funds = msg.value;
        require(funds >= ranges[rangeId].saleData.amount, "The coins sent are not enough");
        
        // Refund
        uint256 refund = (funds).sub(ranges[rangeId].saleData.amount);
        if (refund > 0) {
            (success, ) = (_msgSender()).call{value: refund}("");    
            require(success, "Failed when send back coins to caller");
        }
        
        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        
        uint256 fundsLeft = ranges[rangeId].saleData.amount;
        
    
        if (fundsLeft>0) {
            (success, ) = (owner).call{value: fundsLeft}("");    
            require(success, "Failed when send coins to owner");
        }
        
        
        
        removeFromSale(tokenId);
        
    }
    
    /**
     * buying token. new owner need to pay for nft by tokens(See {INFT-SalesData-erc20Address}). Also payment to author is expected
     * @param tokenId NFT tokenId
     */
    function buyWithToken(
        uint256 tokenId
    )
        public 
        nonReentrant
    {
        (, uint256 rangeId, bool isSingle) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        
        _validateOnlySale(rangeId);
        _validateOnlySaleForTokens(rangeId);
        if (!isSingle) {
            (, rangeId) = splitSeries(tokenId);
        }

        uint256 needToObtain = ranges[rangeId].saleData.amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(ranges[rangeId].saleData.erc20Address);
        uint256 minAmount = saleToken.allowance(_msgSender(), address(this)).min(saleToken.balanceOf(_msgSender()));
        
        require (minAmount >= needToObtain, "The allowance tokens are not enough");
        
        bool success;
        
        success = saleToken.transferFrom(_msgSender(), address(this), needToObtain);
        // require(success, "Failed when 'transferFrom' funds");
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
        require(success);

        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        if (needToObtain>0) {
            success = saleToken.transfer(owner, needToObtain);
            // require(success, "Failed when 'transfer' funds to owner");
            // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
            require(success);
        }
        removeFromSale(tokenId);
    }
    
    /**
     * anyone can offer to pay commission to any tokens transfer
     * @param tokenId NFT tokenId
     * @param amount amount of token(See {INFT-ComissionSettings-token}) 
     */
    function offerToPayCommission(
        uint256 tokenId, 
        uint256 amount 
    )
        public 
    {
        (uint256 serieId, uint256 rangeId,) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        
        (, uint256 newRangeId) = __splitSeries(serieId, rangeId, tokenId);
        
        if (amount == 0) {
            if (ranges[newRangeId].commission.offerAddresses.contains(_msgSender())) {
                ranges[newRangeId].commission.offerAddresses.remove(_msgSender());
                delete ranges[newRangeId].commission.offerPayAmount[_msgSender()];
            }
        } else {
            ranges[newRangeId].commission.offerPayAmount[_msgSender()] = amount;
            ranges[newRangeId].commission.offerAddresses.add(_msgSender());
        }
    }
    
    /**
     * reduce commission. author can to allow a token transfer for free to setup reduce commission to 10000(100%)
     * @param tokenId NFT tokenId
     * @param reduceCommissionPercent commission in percent. can be in interval [0;10000]
     */
    function reduceCommission(
        uint256 tokenId,
        uint256 reduceCommissionPercent
    ) 
        public
    {
        (uint256 serieId, uint256 rangeId, ) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        _validateTokenAuthor(rangeId);
        _validateReduceCommission(reduceCommissionPercent);
        
        (, uint256 newRangeId) = __splitSeries(serieId, rangeId, tokenId);
        
        ranges[newRangeId].commission.reduceCommission = reduceCommissionPercent;
    }
    
    function _create(
        string memory URI,
        CommissionParams memory commissionParams,
        uint256 tokenAmount
    ) 
        internal 
        canRecord(communitySettings.roleMint) 
        returns(uint256 serieId, uint256 rangeId)
    {
               
        require(commissionParams.token != address(0), "wrong token");
        require(commissionParams.intervalSeconds > 0, "wrong intervalSeconds");
        _validateReduceCommission(commissionParams.reduceCommission);
        
        (serieId, rangeId) = _mint(msg.sender, URI, tokenAmount, commissionParams);  
    }
    
    
    function _preListForSale(
        uint256 tokenId
    )
        internal
        returns(uint256 newRangeId)
    {
         
        (uint256 serieId, uint256 rangeId, ) = _getSeriesIds(tokenId);
        _validateTokenExists(rangeId);
        _validateTokenOwner(rangeId);
        
        (, newRangeId) = __splitSeries(serieId, rangeId, tokenId);
    }
    
    function _postListForSale(
        uint256 rangeId,
        uint256 tokenId,
        uint256 amount,
        address consumeToken
    )
        internal
    {
       _listForSale(rangeId, amount, consumeToken);

        emit TokenAddedToSale(tokenId, amount, consumeToken);
    }
    
    function _listForSale(
        uint256 rangeId,
        uint256 amount,
        address consumeToken
    )
        internal
    {
         
        ranges[rangeId].saleData.amount = amount;
        ranges[rangeId].saleData.isSale = true;
        ranges[rangeId].saleData.erc20Address = consumeToken;
        
    }
    
    
     function _transfer(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
        override 
    {
        (, uint256 newSeriesPartsId) = splitSeries(tokenId);
        _transferHook(tokenId, newSeriesPartsId);
        
        // then usual transfer as expected
        super._transfer(from, to, tokenId);
    }
    
    function _validateReduceCommission(uint256 _reduceCommission) internal pure {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "wrong reduceCommission");
    }
    function _validateOnlySale(uint256 rangeId) internal view {
        require(ranges[rangeId].saleData.isSale == true, "Token does not in sale");
    }
    function _validateOnlySaleForCoins(uint256 rangeId) internal view {
        require(ranges[rangeId].saleData.erc20Address == address(0), "sale for coins only");
    }
    function _validateOnlySaleForTokens(uint256 rangeId) internal view {
        require(ranges[rangeId].saleData.erc20Address != address(0), "sale for tokens only");
    }
    
    /**
     * method realized collect commission logic
     * @param tokenId token ID
     */
    function _transferHook(
        uint256 tokenId,
        uint256 rangeId
    ) 
        private
    {
        address author = ranges[rangeId].author;
        address owner = ranges[rangeId].owner;
        
        address commissionToken;
        uint256 commissionAmount;
        (commissionToken, commissionAmount) = _getCommission(tokenId);
        
        if (author == address(0) || commissionAmount == 0) {
            
        } else {
            
            uint256 commissionAmountLeft = commissionAmount;
            if (ranges[rangeId].commission.offerAddresses.contains(owner)) {
                commissionAmountLeft = _transferPay(tokenId, rangeId, owner, commissionToken, commissionAmountLeft);
            }
            
            
            uint256 len = ranges[rangeId].commission.offerAddresses.length();
            uint256 tmpCommission;
            uint256 i;
            for (i = 0; i < len; i++) {
                tmpCommission = commissionAmountLeft;
                if (tmpCommission > 0) {
                    commissionAmountLeft = _transferPay(tokenId, rangeId, ranges[rangeId].commission.offerAddresses.at(i), commissionToken, tmpCommission);
                }
                if (commissionAmountLeft == 0) {
                    break;
                }
            }
            
            require(commissionAmountLeft == 0, "author's commission should be paid");
            
            // 'transfer' commission to the author
            // if Author have co-authors then pays goes proportionally to co-authors 
            // else all send to author
            // ------------------------
            bool success;
            
            if (commissionAmount > 0) {
                success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
                // require(success, "Failed when 'transfer' funds to author");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                require(success);
            }
            
        }
    }
    
    
     /**
     * doing one interation to transfer commission from {addr} to this contract and returned {commissionAmountNeedToPay} that need to pay
     * @param tokenId token ID
     * @param addr payer's address 
     * @param commissionToken token's address
     * @param commissionAmountNeedToPay left commission that need to pay after transfer
     */
    function _transferPay(
        uint256 tokenId,
        uint256 rangeId,
        address addr,
        address commissionToken,
        uint256 commissionAmountNeedToPay
    ) 
        private
        returns(uint256 commissionAmountLeft)
    {
        uint256 minAmount = (ranges[rangeId].commission.offerPayAmount[addr]).min(IERC20Upgradeable(commissionToken).allowance(addr, address(this))).min(IERC20Upgradeable(commissionToken).balanceOf(addr));
        if (minAmount > 0) {
            if (minAmount > commissionAmountNeedToPay) {
                minAmount = commissionAmountNeedToPay;
                commissionAmountLeft = 0;
            } else {
                commissionAmountLeft = commissionAmountNeedToPay.sub(minAmount);
            }
            bool success = IERC20Upgradeable(commissionToken).transferFrom(addr, address(this), minAmount);
            // require(success, "Failed when 'transferFrom' funds");
            // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
            require(success);
            
            ranges[rangeId].commission.offerPayAmount[addr] = ranges[rangeId].commission.offerPayAmount[addr].sub(minAmount);
            if (ranges[rangeId].commission.offerPayAmount[addr] == 0) {
                delete ranges[rangeId].commission.offerPayAmount[addr];
                ranges[rangeId].commission.offerAddresses.remove(addr);
            }
            
        }
        
    }
    
}
