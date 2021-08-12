// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "solidity-linked-list/contracts/StructuredLinkedList.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

//import "./interfaces/INFT.sol";
import "./interfaces/ICommunity.sol";

import "./NFTSeriesBase.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
contract NFTSeries is NFTSeriesBase, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    CommunitySettings communitySettings;

    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    event TokenRemovedFromSale(uint256 tokenId);
    
    modifier canRecord(string memory communityRole) {
        bool s = _canRecord(communityRole);
        
        require(s == true, "Sender has not in accessible List");
        _;
    }
    
    modifier onlySale(uint256 tokenId) {
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        require(seriesParts[seriesPartId].saleData.isSale == true, "NFT: Token does not in sale");
        _;
    }
    modifier onlySaleForCoins(uint256 tokenId) {
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        require(seriesParts[seriesPartId].saleData.erc20Address == address(0), "NFT: Token can not be sale for coins");
        _;
    }
    modifier onlySaleForTokens(uint256 tokenId) {
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        require(seriesParts[seriesPartId].saleData.erc20Address != address(0), "NFT: Token can not be sale for tokens");
        _;
    }
    
    
    function initialize(
        string memory name,
        string memory symbol,
        CommunitySettings memory communitySettings_
    ) public override initializer {
    //    __NFTAuthorship_init(name, symbol);
        
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
        canRecord(communitySettings.roleMint) 
        virtual  
    {

        require(commissionParams.token != address(0), "NFT: Token address can not be zero");
        require(commissionParams.intervalSeconds > 0, "NFT: IntervalSeconds can not be zero");
        _validateReduceCommission(commissionParams.reduceCommission);
        
        _mint(msg.sender, URI, tokenAmount, commissionParams);  
        
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
        onlyIfTokenExists(tokenId)
        returns(address t, uint256 r)
    {
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
        require(funds > 0, "NFT: There are no lost tokens");
            
        bool success = IERC20Upgradeable(erc20address).transfer(_msgSender(), funds);
        require(success, "NFT: Failed when 'transferFrom' funds");
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
        onlyIfTokenExists(tokenId)
        onlyNFTOwner(tokenId)
    {

        
        uint256 newSeriesPartsId;
        (, newSeriesPartsId) = splitSeries(tokenId);
        
        seriesParts[newSeriesPartsId].saleData.amount = amount;
        seriesParts[newSeriesPartsId].saleData.isSale = true;
        seriesParts[newSeriesPartsId].saleData.erc20Address = consumeToken;
        
        emit TokenAddedToSale(tokenId, amount, consumeToken);
    }
    
    /**
     * remove NFT from list for sale.
     * @param tokenId NFT tokenId
     */
    function removeFromSale(
        uint256 tokenId
    )
        public 
        onlyIfTokenExists(tokenId)
        onlyNFTOwner(tokenId)
    {

        (, uint256 newSeriesPartsId) = splitSeries(tokenId);
        
        seriesParts[newSeriesPartsId].saleData.isSale = false;    
        
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
        onlyIfTokenExists(tokenId)
        onlySale(tokenId)
        returns(address, uint256)
    {
        (, uint256 seriesPartId) = _getSeriesIds(tokenId);
        
        return (seriesParts[seriesPartId].saleData.erc20Address, seriesParts[seriesPartId].saleData.amount);
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
        onlyIfTokenExists(tokenId)
        onlySale(tokenId)
        onlySaleForCoins(tokenId)
    {
        
        (,uint256 seriesPartId) = _getSeriesIds(tokenId);
        
        bool success;
        uint256 funds = msg.value;
        require(funds >= seriesParts[seriesPartId].saleData.amount, "NFT: The coins sent are not enough");
        
        // Refund
        uint256 refund = (funds).sub(seriesParts[seriesPartId].saleData.amount);
        if (refund > 0) {
            (success, ) = (_msgSender()).call{value: refund}("");    
            require(success, "NFT: Failed when send back coins to caller");
        }
        
        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        (success, ) = (owner).call{value: seriesParts[seriesPartId].saleData.amount}("");    
        require(success, "NFT: Failed when send coins to owner");
        
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
        onlyIfTokenExists(tokenId)
        onlySale(tokenId)
        onlySaleForTokens(tokenId)
    {
        
        (, uint256 seriesPartId) = _getSeriesIds(tokenId);
        
        uint256 needToObtain = seriesParts[seriesPartId].saleData.amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(seriesParts[seriesPartId].saleData.erc20Address);
        uint256 minAmount = saleToken.allowance(_msgSender(), address(this)).min(saleToken.balanceOf(_msgSender()));
        
        require (minAmount >= needToObtain, "NFT: The allowance tokens are not enough");
        
        bool success;
        
        success = saleToken.transferFrom(_msgSender(), address(this), needToObtain);
        require(success, "NFT: Failed when 'transferFrom' funds");

        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        success = saleToken.transfer(owner, needToObtain);
        require(success, "NFT: Failed when 'transfer' funds to owner");
            
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
        onlyIfTokenExists(tokenId)
    {
        (, uint256 newSeriesPartsId) = splitSeries(tokenId);
        
        if (amount == 0) {
            if (seriesParts[newSeriesPartsId].commission.offerAddresses.contains(_msgSender())) {
                seriesParts[newSeriesPartsId].commission.offerAddresses.remove(_msgSender());
                delete seriesParts[newSeriesPartsId].commission.offerPayAmount[_msgSender()];
            }
        } else {
            seriesParts[newSeriesPartsId].commission.offerPayAmount[_msgSender()] = amount;
            seriesParts[newSeriesPartsId].commission.offerAddresses.add(_msgSender());
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
        onlyIfTokenExists(tokenId)
        onlyNFTAuthor(tokenId)
    {
        (, uint256 newSeriesPartsId) = splitSeries(tokenId);
        _validateReduceCommission(reduceCommissionPercent);
        
        seriesParts[newSeriesPartsId].commission.reduceCommission = reduceCommissionPercent;
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
    
    /**
     * method realized collect commission logic
     * @param tokenId token ID
     */
    function _transferHook(
        uint256 tokenId,
        uint256 seriesPartId
    ) 
        private
    {
        
        address author = seriesParts[seriesPartId].author;
        address owner = seriesParts[seriesPartId].owner;
        
        address commissionToken;
        uint256 commissionAmount;
        (commissionToken, commissionAmount) = _getCommission(tokenId);
        
        if (author == address(0) || commissionAmount == 0) {
            
        } else {
            
            uint256 commissionAmountLeft = commissionAmount;
            if (seriesParts[seriesPartId].commission.offerAddresses.contains(owner)) {
                commissionAmountLeft = _transferPay(tokenId, seriesPartId, owner, commissionToken, commissionAmountLeft);
            }
            
            uint256 len = seriesParts[seriesPartId].commission.offerAddresses.length();
            uint256 tmpI;
            for (uint256 i = 0; i < len; i++) {
                tmpI = commissionAmountLeft;
                if (tmpI > 0) {
                    commissionAmountLeft  = _transferPay(tokenId, seriesPartId, seriesParts[seriesPartId].commission.offerAddresses.at(i), commissionToken, tmpI);
                }
                if (commissionAmountLeft == 0) {
                    break;
                }
            }
            
            require(commissionAmountLeft == 0, "NFT: author's commission should be paid");
            
            // 'transfer' commission to the author
            bool success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
            require(success, "NFT: Failed when 'transfer' funds to author");
        
        }
    }
    
    
    function _validateReduceCommission(
        uint256 _reduceCommission
    ) 
        internal 
        pure
    {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "NFT: reduceCommission can be in interval [0;10000]");
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
        uint256 seriesPartId,
        address addr,
        address commissionToken,
        uint256 commissionAmountNeedToPay
    ) 
        private
        returns(uint256 commissionAmountLeft)
    {
        uint256 minAmount = (seriesParts[seriesPartId].commission.offerPayAmount[addr]).min(IERC20Upgradeable(commissionToken).allowance(addr, address(this))).min(IERC20Upgradeable(commissionToken).balanceOf(addr));
        if (minAmount > 0) {
            if (minAmount > commissionAmountNeedToPay) {
                minAmount = commissionAmountNeedToPay;
                commissionAmountLeft = 0;
            } else {
                commissionAmountLeft = commissionAmountNeedToPay.sub(minAmount);
            }
            bool success = IERC20Upgradeable(commissionToken).transferFrom(addr, address(this), minAmount);
            require(success, "NFT: Failed when 'transferFrom' funds");
            
            seriesParts[seriesPartId].commission.offerPayAmount[addr] = seriesParts[seriesPartId].commission.offerPayAmount[addr].sub(minAmount);
            if (seriesParts[seriesPartId].commission.offerPayAmount[addr] == 0) {
                delete seriesParts[seriesPartId].commission.offerPayAmount[addr];
                seriesParts[seriesPartId].commission.offerAddresses.remove(addr);
            }
            
        }
        
    }
    
    /**
     * return true if {roleName} exist in Community contract for msg.sender
     * @param roleName role name
     */
    function _canRecord(
        string memory roleName
    ) 
        private 
        view 
        returns(bool s)
    {
        s = false;
        if (communitySettings.addr == address(0)) {
            // if the community address set to zero then we must skip the check
            s = true;
        } else {
            string[] memory roles = ICommunity(communitySettings.addr).getRoles(msg.sender);
            for (uint256 i=0; i< roles.length; i++) {
                
                if (keccak256(abi.encodePacked(roleName)) == keccak256(abi.encodePacked(roles[i]))) {
                    s = true;
                }
            }
        }

    }
}
