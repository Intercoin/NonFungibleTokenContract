// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ICommunity.sol";

import "./NFTStruct.sol";
import "./NFTAuthorship.sol";

contract NFT is NFTStruct, NFTAuthorship, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    CountersUpgradeable.Counter private _tokenIds;
    
    CommunitySettings communitySettings;

    // Mapping from token ID to commission
    mapping (uint256 => CommissionSettings) private _commissions;
    
    mapping (uint256 => SalesData) private _salesData;
    
    event NewTokenAppear(address author, uint256 tokenId);
    event TokenAddedToSale(uint256 tokenId, uint256 amount);
    event TokenRemovedFromSale(uint256 tokenId);
    
    modifier canRecord(string memory communityRole) {
        bool s = _canRecord(communityRole);
        
        require(s == true, "Sender has not in accessible List");
        _;
    }
    
    modifier onlyNFTOwner(uint256 tokenId) {
        require(_msgSender() == ownerOf(tokenId), "NFT: sender is not owner of token");
        _;
    }
    modifier onlySale(uint256 tokenId) {
        require(_salesData[tokenId].isSale == true, "NFT: Token does not in sale");
        _;
    }
    
    function initialize(
        string memory name,
        string memory symbol,
        CommunitySettings memory communitySettings_
    ) public initializer {
        __NFTAuthorship_init(name, symbol);
        communitySettings = communitySettings_;
    }
    
   
    /**
     * @param URI Toke URI
     * @param commissionParams commission will be send to author when token's owner sell to someone it
     */
    function create(
        string memory URI,
        CommissionParams memory commissionParams
    ) 
        public 
        canRecord(communitySettings.roleMint) 
        virtual  
    {

        uint256 tokenId = _tokenIds.current();
        
        emit NewTokenAppear(_msgSender(), tokenId);
        
        // We cannot just use balanceOf or totalSupply to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _safeMint(msg.sender, tokenId);
        
        _setTokenURI(tokenId, URI);
        
        require(_commissions[tokenId].token != address(0), "NFT: Token address can not be zero");
        
        _commissions[tokenId].token = commissionParams.token;
        _commissions[tokenId].amount = commissionParams.amount;
        _commissions[tokenId].multiply = (commissionParams.multiply == 0 ? 10000 : commissionParams.multiply);
        _commissions[tokenId].intervalSeconds = commissionParams.intervalSeconds;
        _commissions[tokenId].createdTs = block.timestamp;
        

        _tokenIds.increment();
    }
    
    function getCommission(
        uint256 tokenId
    ) 
        public
        view
        returns(address t, uint256 r)
    {
        (t, r) = _getCommission(tokenId);
    }
    
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
    
    function listForSale(
        uint256 tokenId,
        uint256 amount
    )
        public 
        onlyNFTOwner(tokenId)
    {
        _salesData[tokenId].amount = amount;
        _salesData[tokenId].isSale = true;
        emit TokenAddedToSale(tokenId, amount);
    }
    
    function removeFromSale(
        uint256 tokenId
    )
        public 
        onlyNFTOwner(tokenId)
    {
        _salesData[tokenId].isSale = false;    
        
        emit TokenRemovedFromSale(tokenId);
    }
    
    function buy(
        uint256 tokenId
    )
        public 
        payable
        nonReentrant
        onlySale(tokenId)
    {
        require(_exists(tokenId), "NFT: Nonexistent token");
        //require(_commissionsPayed[tokenId] == false, "NFT: Commission already payed");
        
        bool success;
        uint256 funds = msg.value;
        require(funds >= _salesData[tokenId].amount, "NFT: The coins sent are not enough");
        
        // Refund
        uint256 refund = (funds).sub(_commissions[tokenId].amount);
        if (refund > 0) {
            (success, ) = (_msgSender()).call{value: refund}("");    
            require(success, "NFT: Failed when send back coins to caller");
        }
        
        address owner = ownerOf(tokenId);
        super._transfer(owner, _msgSender(), tokenId);
        
        removeFromSale(tokenId);
        
    }
    
    function offerToPayCommission(
        uint256 tokenId, 
        uint256 amount
    )
        public 
    {
        require(_exists(tokenId), "NFT: Nonexistent token");
        if (amount == 0) {
            if (_salesData[tokenId].offerAddresses.contains(_msgSender())) {
                _salesData[tokenId].offerAddresses.remove(_msgSender());
                delete _salesData[tokenId].offerPayAmount[_msgSender()];
            }
        } else {
            _salesData[tokenId].offerPayAmount[_msgSender()] = amount;
            _salesData[tokenId].offerAddresses.add(_msgSender());
        }

    }
    
    /*
    function payCommissionToken(
        uint256 tokenId
    ) 
        public 
        nonReentrant
    {
        require(_exists(tokenId), "NFT: Nonexistent token");
        
        bool success;
        address author = authorOf(tokenId);
        
        address commissionToken;
        uint256 commissionAmount;
        (commissionToken, commissionAmount) = _getCommission(tokenId);
        
        // check allowance
        uint256 funds = IERC20Upgradeable(commissionToken).allowance(_msgSender(), address(this));
        require(funds >= commissionAmount, "NFT: The funds sent are not enough");
        
        // 'transferFrom'  from sender
        success = IERC20Upgradeable(commissionToken).transferFrom(_msgSender(), address(this), commissionAmount);
        require(success, "NFT: Failed when 'transferFrom' funds");
        
        // 'transfer' to author
        success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
        require(success, "NFT: Failed when send commission to author");
        
     
    }
    
    */
    
    
    function _getCommission(
        uint256 tokenId
    ) 
        internal 
        virtual
        view
        returns(address t, uint256 r)
    {
        /*
        r = initialCommission
        if (multiply === 10000) {
           return r;
        }
        seconds  = now - createdTims
        times = seconds / intervalSeconds
        for i = 1 to times
           r = initial .mul(multiply).div (10000)
        return r;
        */
        
        //initialCommission
        r = _commissions[tokenId].amount;
        t = _commissions[tokenId].token;
        
        if (_commissions[tokenId].multiply == 10000) {
            // left initial commission
        } else {
            uint256 secondsPass = block.timestamp.sub(_commissions[tokenId].createdTs);
    
            uint256 periodTimes = secondsPass.div(_commissions[tokenId].intervalSeconds);
                
            for(uint256 i = 0; i < periodTimes; i++) {
                r = r.mul(periodTimes)
                 .mul(_commissions[tokenId].multiply)
                 .div(10000)
                ;
            }
        
        }
        
    }
    
    
    
   
    
    
    function _transfer(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
        override 
    {
        address author = authorOf(tokenId);
        address owner = ownerOf(tokenId);
        
        address commissionToken;
        uint256 commissionAmount;
        (commissionToken, commissionAmount) = _getCommission(tokenId);
        
        uint256 commissionAmountLeft = commissionAmount;
        if (_salesData[tokenId].offerAddresses.contains(owner)) {
            commissionAmountLeft = _transferPay(tokenId, owner, commissionToken, commissionAmountLeft);
            
            uint256 len = _salesData[tokenId].offerAddresses.length();
            for (uint256 i = 1; i <= len; i++) {
                if (commissionAmountLeft > 0) {
                    commissionAmountLeft  = _transferPay(tokenId, _salesData[tokenId].offerAddresses.at(i), commissionToken, commissionAmountLeft);
                }
                if (commissionAmountLeft == 0) {
                    break;
                }
            }
        }
        
        require(commissionAmountLeft == 0, "NFT: author's commission should be payed");
        
        // 'transfer' commission to the author
        bool success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
        require(success, "NFT: Failed when 'transfer' funds to owner");
        
        // then usual transfer as expected
        super._transfer(from, to, tokenId);
        
    }
    
    
    function _transferPay(
        uint256 tokenId,
        address addr,
        address commissionToken,
        uint256 commissionAmountNeedToPay
    ) 
        private
        returns(uint256 commissionAmountLeft)
    {
        uint256 minAmount;
        
        minAmount = (_salesData[tokenId].offerPayAmount[addr]).min(IERC20Upgradeable(commissionToken).allowance(addr, address(this))).min(IERC20Upgradeable(commissionToken).balanceOf(addr));
        if (minAmount > 0) {
            if (minAmount > commissionAmountNeedToPay) {
                minAmount = commissionAmountNeedToPay;
                commissionAmountLeft = 0;
            } else {
                commissionAmountLeft = commissionAmountNeedToPay.sub(minAmount);
            }
            bool success = IERC20Upgradeable(commissionToken).transferFrom(addr, address(this), minAmount);
            require(success, "NFT: Failed when 'transferFrom' funds");
        }
        
    }
    
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