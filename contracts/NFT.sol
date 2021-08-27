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
    using CoAuthors for CoAuthors.List;
    
    CommunitySettings communitySettings;
    
    struct TokenData {
        CoAuthors.List onetimeConsumers;
        CommissionSettings commissions;
        SalesData salesData;
    }
    
    mapping (uint256 => TokenData) private tokenData;
    
    // Mapping from token ID to commission
    // mapping (uint256 => CommissionSettings) private _commissions;
    
    // mapping (uint256 => SalesData) private _salesData;
    
    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    event TokenRemovedFromSale(uint256 tokenId);
    
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
    
    function listForSale(
        uint256 tokenId,
        uint256 amount,
        address consumeToken,
        CoAuthors.Ratio[] memory proportions
    )
        public
        onlyIfTokenExists(tokenId)
        onlyNFTOwner(tokenId)
    {
        _listForSale(tokenId, amount, consumeToken);
        
        tokenData[tokenId].onetimeConsumers.smartAdd(proportions, _getAuthor(tokenId));
        
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
        tokenData[tokenId].salesData.isSale = false;    
        
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
        //onlySale(tokenId)
        returns(address, uint256, bool)
    {
        return (tokenData[tokenId].salesData.erc20Address, tokenData[tokenId].salesData.amount, tokenData[tokenId].salesData.isSale);
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

        bool success;
        uint256 funds = msg.value;
        require(funds >= tokenData[tokenId].salesData.amount, "NFT: The coins sent are not enough");
        
        // Refund
        uint256 refund = (funds).sub(tokenData[tokenId].salesData.amount);
        if (refund > 0) {
            (success, ) = (_msgSender()).call{value: refund}("");    
            require(success, "NFT: Failed when send back coins to caller");
        }
        
        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        uint256 fundsLeft = tokenData[tokenId].salesData.amount;
        funds = tokenData[tokenId].salesData.amount;
        
        uint256 len = tokenData[tokenId].onetimeConsumers.length();

        if (len > 0) {
            uint256 tmpFunds;     
            address tmpAddr;
            for (uint256 i = 0; i < len; i++) {
                
                //(tmpAddr, tmpFunds) = tokenData[tokenId].onetimeConsumers.at(i);
                (tmpAddr, tmpFunds) = getConsumerTuple(tokenId,i);
                
                tmpFunds = (funds).mul(tmpFunds).div(100);
                
                (success, ) = (tmpAddr).call{value: tmpFunds}("");    
                require(success, "Failed when send coins");
        
                fundsLeft = fundsLeft.sub(tmpFunds);
            }
        }

        if (fundsLeft>0) {
            (success, ) = (owner).call{value: fundsLeft}("");    
            require(success, "Failed when send coins to owner");
        }
        
        removeFromSale(tokenId);
       
    }
    
    /**
     * additional method to avoid stack too deep error
     */
    function getConsumerTuple(uint256 tokenId, uint256 i) internal view returns(address a, uint256 f) {
        (a,f) = tokenData[tokenId].onetimeConsumers.at(i);
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
        
        uint256 needToObtain = tokenData[tokenId].salesData.amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address);
        uint256 minAmount = saleToken.allowance(_msgSender(), address(this)).min(saleToken.balanceOf(_msgSender()));
        
        require (minAmount >= needToObtain, "NFT: The allowance tokens are not enough");
       
        bool success;
        
        success = saleToken.transferFrom(_msgSender(), address(this), needToObtain);
        require(success, "NFT: Failed when 'transferFrom' funds");

        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
     
        uint256 needToObtainLeft = needToObtain;
           
        uint256 len = tokenData[tokenId].onetimeConsumers.length();
        if (len > 0) {
            uint256 tmpCommission;     
            address tmpAddr;
            for (uint256 i = 0; i < len; i++) {
                //(tmpAddr, tmpCommission) = tokenData[tokenId].onetimeConsumers.at(i);
                (tmpAddr, tmpCommission) = getConsumerTuple(tokenId,i);
                
                tmpCommission = needToObtain.mul(tmpCommission).div(100);
                
                success = saleToken.transfer(tmpAddr, tmpCommission);
                // require(success, "Failed when 'transfer' funds to co-author");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                require(success);
                needToObtainLeft = needToObtainLeft.sub(tmpCommission);
            }
            
        }

        if (needToObtainLeft>0) {
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
        tokenData[tokenId].salesData.amount = amount;
        tokenData[tokenId].salesData.isSale = true;
        tokenData[tokenId].salesData.erc20Address = consumeToken;
        emit TokenAddedToSale(tokenId, amount, consumeToken);
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
    /**
     * method realized collect commission logic
     * @param tokenId token ID
     */
    function _transferHook(
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
            
            
            
            // 'transfer' commission to the author
            // if Author have co-authors then pays goes proportionally to co-authors 
            // then 
            //      if was set onetimeConsumers then 
            //          pays goes proportionally to them
            //          and finally left send to main author
            //      else all send to main author
            // ------------------------
            
            bool success;
            address tmpAddr;
            commissionAmountLeft = commissionAmount;
            len = _coauthors[tokenId].length();
            
            if (len == 0) {

            } else {
                
                for (i = 0; i < len; i++) {
                    (tmpAddr, tmpCommission) = _coauthors[tokenId].at(i);
                    tmpCommission = commissionAmount.mul(tmpCommission).div(100);
                    
                    success = IERC20Upgradeable(commissionToken).transfer(tmpAddr, tmpCommission);
                    // require(success, "Failed when 'transfer' funds to co-author");
                    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                    require(success);
                    commissionAmountLeft = commissionAmountLeft.sub(tmpCommission);
                }
                
                
            }
            
            if (commissionAmountLeft > 0) {    
                success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmountLeft);
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
    
    function _validateReduceCommission(
        uint256 _reduceCommission
    ) 
        internal 
        pure
    {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "NFT: reduceCommission can be in interval [0;10000]");
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