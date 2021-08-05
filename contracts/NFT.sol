// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";


import "./interfaces/ICommunity.sol";
import "./interfaces/INFT.sol";

import "./NFTAuthorship.sol";


contract NFT is INFT, NFTAuthorship {
    
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    
    
    CommunitySettings communitySettings;

    // Mapping from token ID to commission
    mapping (uint256 => CommissionSettings) private _commissions;
    
    mapping (uint256 => SalesData) private _salesData;
    
    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    event TokenRemovedFromSale(uint256 tokenId);
    
    modifier canRecord(string memory communityRole) {
        bool s = _canRecord(communityRole);
        
        require(s == true, "Sender has not in accessible List");
        _;
    }
    
    modifier onlySale(uint256 tokenId) {
        require(_salesData[tokenId].isSale == true, "NFT: Token does not in sale");
        _;
    }
    modifier onlySaleForCoins(uint256 tokenId) {
        require(_salesData[tokenId].erc20Address == address(0), "NFT: Token can not be sale for coins");
        _;
    }
    modifier onlySaleForTokens(uint256 tokenId) {
        require(_salesData[tokenId].erc20Address != address(0), "NFT: Token can not be sale for tokens");
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
        uint256 tokenId = _create(URI);
        
        require(commissionParams.token != address(0), "NFT: Token address can not be zero");
        require(commissionParams.intervalSeconds > 0, "NFT: IntervalSeconds can not be zero");
        _validateReduceCommission(commissionParams.reduceCommission);
        
        _commissions[tokenId].token = commissionParams.token;
        _commissions[tokenId].amount = commissionParams.amount;
        _commissions[tokenId].multiply = (commissionParams.multiply == 0 ? 10000 : commissionParams.multiply);
        _commissions[tokenId].accrue = commissionParams.accrue;
        _commissions[tokenId].intervalSeconds = commissionParams.intervalSeconds;
        _commissions[tokenId].reduceCommission = commissionParams.reduceCommission;
        _commissions[tokenId].createdTs = block.timestamp;
        _commissions[tokenId].lastTransferTs = block.timestamp;
      
        _createAfter();
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
        _salesData[tokenId].amount = amount;
        _salesData[tokenId].isSale = true;
        _salesData[tokenId].erc20Address = consumeToken;
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
        _salesData[tokenId].isSale = false;    
        
        emit TokenRemovedFromSale(tokenId);
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
        require(funds >= _salesData[tokenId].amount, "NFT: The coins sent are not enough");
        
        // Refund
        uint256 refund = (funds).sub(_salesData[tokenId].amount);
        if (refund > 0) {
            (success, ) = (_msgSender()).call{value: refund}("");    
            require(success, "NFT: Failed when send back coins to caller");
        }
        
        address owner = ownerOf(tokenId);
        _transfer(owner, _msgSender(), tokenId);
        
        (success, ) = (owner).call{value: _salesData[tokenId].amount}("");    
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
        
        uint256 needToObtain = _salesData[tokenId].amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(_salesData[tokenId].erc20Address);
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
        if (amount == 0) {
            if (_commissions[tokenId].offerAddresses.contains(_msgSender())) {
                _commissions[tokenId].offerAddresses.remove(_msgSender());
                delete _commissions[tokenId].offerPayAmount[_msgSender()];
            }
        } else {
            _commissions[tokenId].offerPayAmount[_msgSender()] = amount;
            _commissions[tokenId].offerAddresses.add(_msgSender());
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
        
        _commissions[tokenId].reduceCommission = reduceCommissionPercent;
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
        r = _commissions[tokenId].amount;
        t = _commissions[tokenId].token;
        if (r == 0) {
            
        } else {
            if (_commissions[tokenId].multiply == 10000) {
                // left initial commission
            } else {
                
                uint256 intervalsSinceCreate = (block.timestamp.sub(_commissions[tokenId].createdTs)).div(_commissions[tokenId].intervalSeconds);
                uint256 intervalsSinceLastTransfer = (block.timestamp.sub(_commissions[tokenId].lastTransferTs)).div(_commissions[tokenId].intervalSeconds);
                
                // (   
                //     initialValue * (multiply ^ intervals) + (intervalsSinceLastTransfer * accrue)
                // ) * (10000 - reduceCommission) / 10000
                
                for(uint256 i = 0; i < intervalsSinceCreate; i++) {
                    r = r.mul(_commissions[tokenId].multiply).div(10000);
                    
                }
                
                r = r.add(
                        intervalsSinceLastTransfer.mul(_commissions[tokenId].accrue)
                    );
                
                r = r.mul(
                        uint256(10000).sub(_commissions[tokenId].reduceCommission)
                    ).div(uint256(10000));
                
            }
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
            if (_commissions[tokenId].offerAddresses.contains(owner)) {
                commissionAmountLeft = _transferPay(tokenId, owner, commissionToken, commissionAmountLeft);
            }
            
            uint256 len = _commissions[tokenId].offerAddresses.length();
            uint256 tmpI;
            for (uint256 i = 0; i < len; i++) {
                tmpI = commissionAmountLeft;
                if (tmpI > 0) {
                    commissionAmountLeft  = _transferPay(tokenId, _commissions[tokenId].offerAddresses.at(i), commissionToken, tmpI);
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
        uint256 minAmount = (_commissions[tokenId].offerPayAmount[addr]).min(IERC20Upgradeable(commissionToken).allowance(addr, address(this))).min(IERC20Upgradeable(commissionToken).balanceOf(addr));
        if (minAmount > 0) {
            if (minAmount > commissionAmountNeedToPay) {
                minAmount = commissionAmountNeedToPay;
                commissionAmountLeft = 0;
            } else {
                commissionAmountLeft = commissionAmountNeedToPay.sub(minAmount);
            }
            bool success = IERC20Upgradeable(commissionToken).transferFrom(addr, address(this), minAmount);
            require(success, "NFT: Failed when 'transferFrom' funds");
            
            _commissions[tokenId].offerPayAmount[addr] = _commissions[tokenId].offerPayAmount[addr].sub(minAmount);
            if (_commissions[tokenId].offerPayAmount[addr] == 0) {
                delete _commissions[tokenId].offerPayAmount[addr];
                _commissions[tokenId].offerAddresses.remove(addr);
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
    
    
    function _validateReduceCommission(
        uint256 _reduceCommission
    ) 
        private 
        pure
    {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "NFT: reduceCommission can be in interval [0;10000]");
    }
        
   
}