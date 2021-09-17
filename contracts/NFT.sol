// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "./interfaces/ICommunity.sol";
import "./interfaces/INFT.sol";

import "./NFTAuthorship.sol";

contract NFT is INFT, NFTAuthorship {
    
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    CommunitySettings communitySettings;
    
    struct TokenData {
        CommissionSettings commissions;
        SalesData salesData;
    }
    
    mapping (uint256 => TokenData) private tokenData;
    mapping (uint256 => address[]) private ownersHistory;
    
    EnumerableSetUpgradeable.AddressSet totalOwnersList;
    
    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    event TokenAddedToAuctionSale(uint256 tokenId, uint256 amount, address consumeToken, uint256 startTime, uint256 endTime, uint256 minIncrement);
    event TokenRemovedFromSale(uint256 tokenId);
    event OutBid(uint256 tokenId, uint256 newBid);
    
    modifier canRecord(string memory communityRole) {
        bool s = _canRecord(communityRole);
        require(s == true, "Sender has not in accessible List");
        _;
    }
    
    modifier onlySale(uint256 tokenId) {
        require(tokenData[tokenId].salesData.isSale == true, "NFT: Token does not in sale");
        _;
    }
    modifier onlySaleForCoins(uint256 tokenId) {
        require(tokenData[tokenId].salesData.erc20Address == address(0), "NFT: Token can not be sale for coins");
        _;
    }
    modifier onlySaleForTokens(uint256 tokenId) {
        require(tokenData[tokenId].salesData.erc20Address != address(0), "NFT: Token can not be sale for tokens");
        _;
    }
    
    modifier canClaim(uint256 tokenId) {
        // can claim if auction time == 0 or expire
        // can claim if last bidder is sender
        uint256 len = tokenData[tokenId].salesData.bids.length;
        require(
            (
                tokenData[tokenId].salesData.endTime != 0 && 
                tokenData[tokenId].salesData.endTime < block.timestamp &&
                len > 0 && 
                tokenData[tokenId].salesData.bids[len-1].bidder == _msgSender()
            ), 
            "can't claim"
        );
        _;   
    }
    
    
    /**
     * @param name name of token ERC721 
     * @param symbol symbol of token ERC721 
     * @param communitySettings_ community setting. See {INFT-CommunitySettings}.
     */
    function initialize(
        string memory name,
        string memory symbol,
        CommunitySettings memory communitySettings_
    ) public override initializer {
        __NFTAuthorship_init(name, symbol);
        communitySettings = communitySettings_;
    }
   
    /**
     * creation NFT token
     * @param URI Token URI
     * @param commissionParams commission will be send to author when token's owner sell to someone it. See {INFT-CommissionParams}.
     */
    function create(
        string memory URI,
        CommissionParams memory commissionParams
    ) 
        public 
        canRecord(communitySettings.roleMint) 
        virtual  
    {
        _create(URI, commissionParams);
    }
    
    /**
     * creation NFT token and immediately put to list for sale
     * @param URI Token URI
     * @param commissionParams commission will be send to author when token's owner sell to someone it. See {INFT-CommissionParams}.
     * @param consumeAmount amount that need to be paid to owner when some1 buy token
     * @param consumeToken erc20 token. if set address(0) then expected coins to pay for NFT
     */
    function createAndSale(
        string memory URI,
        CommissionParams memory commissionParams,
        uint256 consumeAmount,
        address consumeToken
    ) 
        public 
        virtual  
    {
        uint256 tokenId = _create(URI, commissionParams);
        
        _listForSale(tokenId, consumeAmount, consumeToken);
    }
    
    /**
     * creation NFT token and immediately put to list for sale
     * @param URI Token URI
     * @param commissionParams commission will be send to author when token's owner sell to someone it. See {INFT-CommissionParams}.
     * @param consumeAmount amount that need to be paid to owner when some1 buy token
     * @param consumeToken erc20 token. if set address(0) then expected coins to pay for NFT
     */
    function createAndSaleAuction(
        string memory URI,
        CommissionParams memory commissionParams,
        uint256 consumeAmount,
        address consumeToken,
        uint256 startTime,
        uint256 endTime,
        uint256 minIncrement
    ) 
        public 
        virtual  
    {
        uint256 tokenId = _create(URI, commissionParams);
        
        _listForAuction(tokenId, consumeAmount, consumeToken, startTime, endTime, minIncrement);
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
        _listForSale(tokenId, amount, consumeToken);
    }

    function listForAuction(
        uint256 tokenId,
        uint256 amount,
        address consumeToken,
        uint256 startTime,
        uint256 endTime,
        uint256 minIncrement
    )
        public
        onlyIfTokenExists(tokenId)
        onlyNFTOwner(tokenId)
    {
        _listForAuction(tokenId, amount, consumeToken, startTime, endTime, minIncrement);
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
        _removeFromSale(tokenId);
    }
    
    /**
     * sale info
     * @param tokenId NFT tokenId
     * @return erc20Address
     * @return amount
     * @return isSale
     * @return startTime
     * @return endTime
     * @return minIncrement
     * @return isAuction
     */
    function saleInfo(
        uint256 tokenId
    )   
        public
        view
        onlyIfTokenExists(tokenId)
        returns(
            address erc20Address, 
            uint256 amount, 
            bool isSale, 
            uint256 startTime, 
            uint256 endTime, 
            uint256 minIncrement, 
            bool isAuction
        )
    {
        erc20Address = tokenData[tokenId].salesData.erc20Address;
        amount = tokenData[tokenId].salesData.amount; 
        isSale = tokenData[tokenId].salesData.isSale;
        startTime = tokenData[tokenId].salesData.startTime;
        endTime = tokenData[tokenId].salesData.endTime;
        minIncrement = tokenData[tokenId].salesData.minIncrement;
        isAuction = tokenData[tokenId].salesData.isAuction;
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
        _validateAuctionActive(tokenId);
        bool success;
        uint256 funds = msg.value;
        require(funds >= tokenData[tokenId].salesData.amount, "NFT: The coins sent are not enough");
        
        
        if (_isInAuction(tokenId) == 1) {
            putInToAuctionList(tokenId, _msgSender(), funds, 0);
        } else {
            // Refund
            uint256 refund = (funds).sub(tokenData[tokenId].salesData.amount);
            if (refund > 0) {
                (success, ) = (_msgSender()).call{value: refund}("");    
                require(success, "NFT: Failed when send back coins to caller");
            }
            
            _executeTransfer(tokenId, _msgSender(), tokenData[tokenId].salesData.amount, 0);
        }
       
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
        _validateAuctionActive(tokenId);
        uint256 needToObtain = tokenData[tokenId].salesData.amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address);
        uint256 minAmount = saleToken.allowance(_msgSender(), address(this)).min(saleToken.balanceOf(_msgSender()));
        
        require (minAmount >= needToObtain, "NFT: The allowance tokens are not enough");
       
        bool success;
        
        success = saleToken.transferFrom(_msgSender(), address(this), needToObtain);
        require(success, "NFT: Failed when 'transferFrom' funds");
        
        if (_isInAuction(tokenId) == 1) {
            putInToAuctionList(tokenId, _msgSender(), needToObtain, 1);
            
        } else {
            _executeTransfer(tokenId, _msgSender(), needToObtain, 1);
        }
        
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
        if (amount == 0) {
            if (tokenData[tokenId].commissions.offerAddresses.contains(_msgSender())) {
                tokenData[tokenId].commissions.offerAddresses.remove(_msgSender());
                delete tokenData[tokenId].commissions.offerPayAmount[_msgSender()];
            }
        } else {
            tokenData[tokenId].commissions.offerPayAmount[_msgSender()] = amount;
            tokenData[tokenId].commissions.offerAddresses.add(_msgSender());
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
        _validateReduceCommission(reduceCommissionPercent);
        
        tokenData[tokenId].commissions.reduceCommission = reduceCommissionPercent;
    }
    
    function claim(
        uint256 tokenId
    )
        public
        onlyIfTokenExists(tokenId)
        onlySale(tokenId)
        canClaim(tokenId)
    {
        _claim(tokenId);
    }
    
    function acceptLastBid(
        uint256 tokenId
    )
        public
        onlyIfTokenExists(tokenId)
        onlySale(tokenId)
        onlyNFTOwner(tokenId)
    {
        uint256 len = tokenData[tokenId].salesData.bids.length;
        if (len > 0) {
            _claim(tokenId);
        } else {
            revert("there are no any bids");
        }
    }
    
    function tokensByOwner(
        address owner
    ) 
        public
        
        view 
        returns(uint256[] memory) 
    {
        uint256 len = 0;
        for (uint256 i = 0; i < currentTokenIds(); i++) {
            if ((_exists(i) == true) && (ownerOf(i) == owner)) {
                len = len.add(1);
            }
        }
        
        uint256[] memory ret = new uint256[](len);
        uint256 index = 0;

        for (uint256 i = 0; i < currentTokenIds(); i++) {
            if ((_exists(i) == true) && (ownerOf(i) == owner)) {
                ret[index] = i;
                index = index.add(1);
            }
        }
        return ret;
    }
    
    function historyOfOwners(
        uint256 tokenId
    )
        public 
        view
        returns(address[] memory) 
    {
        uint256 len = ownersHistory[tokenId].length;
        address[] memory ret = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            ret[i] =  ownersHistory[tokenId][i];
        }
        return ret;
    }
    
    function historyOfBids(
        uint256 tokenId
    )
        public 
        view
        returns(Bid[] memory) 
    {
        uint256 len = tokenData[tokenId].salesData.bids.length;
        Bid[] memory ret = new Bid[](len);

        for (uint256 i = 0; i < len; i++) {
            ret[i] =  tokenData[tokenId].salesData.bids[i];
        }
        return ret;
    }
    
    function getAllOwners(
    ) 
        public
        view 
        returns(address[] memory) 
    {

        uint256 len = totalOwnersList.length();
        address[] memory ret = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            ret[i] = totalOwnersList.at(i);
        }
        return ret;
    }
   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // internal section ///////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    function putInToAuctionList(
        uint256 tokenId, 
        address sender, 
        uint256 amount,
        uint256 typeTransfer
    ) 
        internal 
    {
        uint256 len = tokenData[tokenId].salesData.bids.length;
        
        uint256 prevBid = (len > 0) ? tokenData[tokenId].salesData.bids[len-1].bid : tokenData[tokenId].salesData.amount;
        
        require((prevBid).add(tokenData[tokenId].salesData.minIncrement) <= amount, "bid should be more");
        
        // tokenData[tokenId].salesData.bids[len].bidder = sender;
        // tokenData[tokenId].salesData.bids[len].bid = amount;
        tokenData[tokenId].salesData.bids.push(Bid({bidder: sender, bid: amount}));
        
        if (len > 0) {
            bool success;
            address prevBidder = tokenData[tokenId].salesData.bids[len-1].bidder;
            //uint256 prevBid = tokenData[tokenId].salesData.bids[len-1].bid;
            
            // refund previous
            if (typeTransfer == 0) {
                (success, ) = (prevBidder).call{value: prevBid}("");    
                require(success, "Failed when send coins");
            } else {
                
                success = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address).transfer(prevBidder, prevBid);
                // require(success, "Failed when 'transfer' funds to co-author");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                require(success);
            }
            
            emit OutBid(tokenId, amount);
        }
        
    }
    
    function _claim(
        uint256 tokenId
    )
        internal
    {
        uint256 len = tokenData[tokenId].salesData.bids.length;
        
        address sender = tokenData[tokenId].salesData.bids[len-1].bidder;
        uint256 amount = tokenData[tokenId].salesData.bids[len-1].bid;
        
        _executeTransfer(
            tokenId, 
            sender, 
            amount, 
            (tokenData[tokenId].salesData.erc20Address == address(0)? 0 : 1)
        );
        
    }
    
    /**
     * typeTransfer: 0 - coin;  1 -erc20transfer
     */
    function _executeTransfer(
        uint256 tokenId, 
        address newOwner,
        uint256 needToObtain,
        uint256 typeTransfer
    ) 
        internal
    {
        bool success;
        address owner = ownerOf(tokenId);
        _transfer(owner, newOwner, tokenId);
        
        if (needToObtain>0) {
            if (typeTransfer == 0) {
                (success, ) = (owner).call{value: needToObtain}("");    
            } else {
                
                success = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address).transfer(owner, needToObtain);
                // require(success, "Failed when 'transfer' funds to owner");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
            }
            require(success);
        }
        
        _removeFromSale(tokenId);
    }
    
    function _removeFromSale(
        uint256 tokenId
    )
        internal
    {
        tokenData[tokenId].salesData.isSale = false;
        tokenData[tokenId].salesData.isAuction = false;
        
        emit TokenRemovedFromSale(tokenId);
    }
   
    function _create(
        string memory URI,
        CommissionParams memory commissionParams
    ) 
        internal 
        canRecord(communitySettings.roleMint) 
        returns(uint256 tokenId)
    {
        
        require(commissionParams.token != address(0), "NFT: Token address can not be zero");
        require(commissionParams.intervalSeconds > 0, "NFT: IntervalSeconds can not be zero");
        _validateReduceCommission(commissionParams.reduceCommission);
        
        tokenId = _createNFT(URI);
        
        tokenData[tokenId].commissions.token = commissionParams.token;
        tokenData[tokenId].commissions.amount = commissionParams.amount;
        tokenData[tokenId].commissions.multiply = (commissionParams.multiply == 0 ? 10000 : commissionParams.multiply);
        tokenData[tokenId].commissions.accrue = commissionParams.accrue;
        tokenData[tokenId].commissions.intervalSeconds = commissionParams.intervalSeconds;
        tokenData[tokenId].commissions.reduceCommission = commissionParams.reduceCommission;
        tokenData[tokenId].commissions.createdTs = block.timestamp;
        tokenData[tokenId].commissions.lastTransferTs = block.timestamp;
      
        _createAfter();
    }
    
    function _listForSale(
        uint256 tokenId,
        uint256 amount,
        address consumeToken
    )
        internal
    {
        __listForSale(tokenId, amount, consumeToken);
        emit TokenAddedToSale(tokenId, amount, consumeToken);
    }

    function _listForAuction(
        uint256 tokenId,
        uint256 amount,
        address consumeToken,
        uint256 startTime,
        uint256 endTime,
        uint256 minIncrement
    )
        internal
    {
        require(startTime == 0 || startTime >= block.timestamp, 'wrong startTime' );
        startTime = (startTime == 0) ? block.timestamp : startTime;
        
        require(startTime < endTime || endTime == 0, 'wrong endTime' );
        
        __listForSale(tokenId, amount, consumeToken);
        
        emit TokenAddedToSale(tokenId, amount, consumeToken);
        
        tokenData[tokenId].salesData.startTime = startTime;
        tokenData[tokenId].salesData.endTime = endTime;
        tokenData[tokenId].salesData.minIncrement = minIncrement;
        tokenData[tokenId].salesData.isAuction = true;
        
        emit TokenAddedToAuctionSale(tokenId, amount, consumeToken, startTime, endTime, minIncrement);
    }

    
    /**
     * commission amount that need to be paid while NFT token transferring
     * @param tokenId NFT tokenId
     */
    function _getCommission(
        uint256 tokenId
    ) 
        internal 
        virtual
        view
        returns(address t, uint256 r)
    {
        
        //initialCommission
        r = tokenData[tokenId].commissions.amount;
        t = tokenData[tokenId].commissions.token;
        if (r == 0) {
            
        } else {
            if (tokenData[tokenId].commissions.multiply == 10000) {
                // left initial commission
            } else {
                
                uint256 intervalsSinceCreate = (block.timestamp.sub(tokenData[tokenId].commissions.createdTs)).div(tokenData[tokenId].commissions.intervalSeconds);
                uint256 intervalsSinceLastTransfer = (block.timestamp.sub(tokenData[tokenId].commissions.lastTransferTs)).div(tokenData[tokenId].commissions.intervalSeconds);
                
                // (   
                //     initialValue * (multiply ^ intervals) + (intervalsSinceLastTransfer * accrue)
                // ) * (10000 - reduceCommission) / 10000
                
                for(uint256 i = 0; i < intervalsSinceCreate; i++) {
                    r = r.mul(tokenData[tokenId].commissions.multiply).div(10000);
                    
                }
                
                r = r.add(
                        intervalsSinceLastTransfer.mul(tokenData[tokenId].commissions.accrue)
                    );
                
                
            }
            
            r = r.mul(
                    uint256(10000).sub(tokenData[tokenId].commissions.reduceCommission)
                ).div(uint256(10000));
                
        }
        
    }
  
    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
        override 
    {
        ownersHistory[tokenId].push(to);
        
        if (to != address(0)) {
            totalOwnersList.add(to);
        } 
        
        if ((from != address(0)) && (balanceOf(from) == 1)) {
            totalOwnersList.remove(from);    
        }    
        
        super._beforeTokenTransfer(from, to, tokenId);
    }
    /**
     * method realized collect commission logic
     * @param from from
     * @param to to
     * @param tokenId token ID
     */
    function _transferHook(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual
        override
    {
        
        address author = authorOf(tokenId);
        address owner = ownerOf(tokenId);
        
        address commissionToken;
        uint256 commissionAmount;
        (commissionToken, commissionAmount) = _getCommission(tokenId);
        
        if (author == address(0) || commissionAmount == 0) {
            
        } else {
            
            uint256 commissionAmountLeft = commissionAmount;
            if (tokenData[tokenId].commissions.offerAddresses.contains(owner)) {
                commissionAmountLeft = _transferPay(tokenId, owner, commissionToken, commissionAmountLeft);
            }
            uint256 i;
            uint256 len = tokenData[tokenId].commissions.offerAddresses.length();
            uint256 tmpCommission;
            
            for (i = 0; i < len; i++) {
                tmpCommission = commissionAmountLeft;
                if (tmpCommission > 0) {
                    commissionAmountLeft  = _transferPay(tokenId, tokenData[tokenId].commissions.offerAddresses.at(i), commissionToken, tmpCommission);
                }
                if (commissionAmountLeft == 0) {
                    break;
                }
            }
            
            require(commissionAmountLeft == 0, "NFT: author's commission should be paid");
            
            bool success;
            
            if (commissionAmount > 0) {    
                success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
                // require(success, "Failed when 'transfer' funds to author");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                require(success);
            }
        }
        
    }
    
    function _isInAuction(
        uint256 tokenId
    ) 
        internal 
        view 
        returns(uint256)
    {
        return tokenData[tokenId].salesData.isAuction == true ? 1 : 0;
    }
    
    function _validateReduceCommission(
        uint256 _reduceCommission
    ) 
        internal 
        pure
    {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "NFT: reduceCommission can be in interval [0;10000]");
    }
       
   function _validateAuctionActive(
        uint256 tokenId
    ) 
        internal
        view
    {
        if (tokenData[tokenId].salesData.isAuction == true) {
            require(
                tokenData[tokenId].salesData.startTime <= block.timestamp &&
                (
                    tokenData[tokenId].salesData.endTime >= block.timestamp
                    ||
                    tokenData[tokenId].salesData.endTime == 0
                ), 
                "Auction out of time"
            );
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
        address addr,
        address commissionToken,
        uint256 commissionAmountNeedToPay
    ) 
        private
        returns(uint256 commissionAmountLeft)
    {
        uint256 minAmount = (tokenData[tokenId].commissions.offerPayAmount[addr]).min(IERC20Upgradeable(commissionToken).allowance(addr, address(this))).min(IERC20Upgradeable(commissionToken).balanceOf(addr));
        if (minAmount > 0) {
            if (minAmount > commissionAmountNeedToPay) {
                minAmount = commissionAmountNeedToPay;
                commissionAmountLeft = 0;
            } else {
                commissionAmountLeft = commissionAmountNeedToPay.sub(minAmount);
            }
            bool success = IERC20Upgradeable(commissionToken).transferFrom(addr, address(this), minAmount);
            require(success, "NFT: Failed when 'transferFrom' funds");
            
            tokenData[tokenId].commissions.offerPayAmount[addr] = tokenData[tokenId].commissions.offerPayAmount[addr].sub(minAmount);
            if (tokenData[tokenId].commissions.offerPayAmount[addr] == 0) {
                delete tokenData[tokenId].commissions.offerPayAmount[addr];
                tokenData[tokenId].commissions.offerAddresses.remove(addr);
            }
            
        }
        
    }
     
    function __listForSale(
        uint256 tokenId,
        uint256 amount,
        address consumeToken
    )
        private
    {
        tokenData[tokenId].salesData.amount = amount;
        tokenData[tokenId].salesData.isSale = true;
        tokenData[tokenId].salesData.erc20Address = consumeToken;
        tokenData[tokenId].salesData.isAuction = false;
        
        delete tokenData[tokenId].salesData.bids;
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