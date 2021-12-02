// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

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
        SaleInfo[] saleHistory;
        address[] ownersHistory;
    }
    
    mapping (uint256 => TokenData) private tokenData;

    mapping(address => bool) authorized;

    EnumerableSetUpgradeable.AddressSet private totalOwnersList;
    
    string constant private MSG_TRANSFERFROM_FAILED = "NFT: Failed when 'transferFrom' funds";
    
    event TokenAddedToSale(uint256 tokenId, uint256 amount, address consumeToken);
    // event TokenAddedToAuctionSale(uint256 tokenId, uint256 amount, address consumeToken, uint256 startTime, uint256 endTime, uint256 minIncrement);
    event TokenRemovedFromSale(uint256 tokenId);
    // event OutBid(uint256 tokenId, uint256 newBid);
    
    
    function _validateOnlySale(uint256 tokenId) internal view {
        require(tokenData[tokenId].salesData.isSale == true, "NFT: Token does not in sale");
    }
    function _validateOnlySaleForCoins(uint256 tokenId) internal view {
        require(tokenData[tokenId].salesData.erc20Address == address(0), "NFT: Token can not be sale for coins");   
    }
    function _validateOnlySaleForTokens(uint256 tokenId) internal view {
        require(tokenData[tokenId].salesData.erc20Address != address(0), "NFT: Token can not be sale for tokens");
    }
    function _validateCanClaim(uint256 tokenId) internal view {
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
    
    function buyWithETHAndCreate(
        string memory tokenURI, 
        SaleParams memory saleParams,
        CommissionParams memory commissionParams,
        bytes memory signature
    ) 
        public 
        payable
    {
        _createValidate(tokenURI, saleParams, commissionParams, signature);

        require(msg.value >= saleParams.amount, "insufficient amount");

        //TransferHelper.safeTransferETH(saleParams.seller, saleParams.amount);
        
        saleParams.seller.transfer(saleParams.amount);

        uint256 refund = msg.value.sub(saleParams.amount);
        if (refund > 0) {
            payable(_msgSender()).transfer(refund);
        }

        _create(tokenURI, saleParams.seller, commissionParams);
    }

    function buyWithTokenAndCreate(
        string memory tokenURI, 
        SaleParams memory saleParams,
        CommissionParams memory commissionParams,
        bytes memory signature
    ) 
        public 
    {

        _createValidate(tokenURI, saleParams, commissionParams, signature);

        require(IERC20Upgradeable(saleParams.token).allowance(_msgSender(), address(this)) >= saleParams.amount, "insufficient allowance");

        // TransferHelper.safeTransferFrom(saleParams.token, _msgSender(), address(this), saleParams.amount);
        // TransferHelper.safeTransfer(saleParams.token, saleParams.seller, saleParams.amount);

        TransferHelper.safeTransferFrom(saleParams.token, _msgSender(), saleParams.seller, saleParams.amount);
        
        _create(tokenURI, saleParams.seller, commissionParams);


    }

    function _createValidate(
        string memory tokenURI, 
        SaleParams memory saleParams,
        CommissionParams memory commissionParams,
        bytes memory signature
    ) 
        internal
    {
        require(saleParams.seller != address(0), "wrong seller address");
        bytes memory encoded = abi.encode(tokenURI, saleParams, commissionParams);
        bytes32 hash = keccak256(encoded);
        bytes32 esh = getEthSignedMessageHash(hash);
        
        
        address signer = recoverSigner(esh, signature);

        if (signer != owner()) {

            require (isAuthorized(signer) && signer == saleParams.seller, "Invalid signer");
            
        }

    }

    
    function addAuthorized(address addr) public onlyOwner() {
        require(addr != address(0), "invalid address");
        authorized[addr] = true;
    }
    function removeAuthorized(address addr) public onlyOwner() {
        delete authorized[addr];
    }
    function isAuthorized(address addr) public view returns(bool) {
        return authorized[addr];
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

      function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
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
        // onlyIfTokenExists(tokenId)
        returns(address t, uint256 r)
    {
        _validateOnlyIfTokenExists(tokenId);
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
        require(success, MSG_TRANSFERFROM_FAILED);
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
        // onlyIfTokenExists(tokenId)
        // onlyNFTOwner(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlyNFTOwner(tokenId);
        _listForSale(tokenId, amount, consumeToken);
    }

    /**
     * put NFT to list for auction sale. then anyone can put a bid to buy it
     * @param tokenId NFT tokenId
     * @param amount amount that need to be paid to owner when some1 buy token
     * @param consumeToken erc20 token. if set address(0) then expected coins to pay for NFT
     * @param startTime time when auction will start. can be zero, then auction will start immediately
     * @param endTime time when auction will end. can be zero, then auction will never expire
     * @param minIncrement every new bid should be more then [previous bid] plus [minIncrement]
     */
    // function listForAuction(
    //     uint256 tokenId,
    //     uint256 amount,
    //     address consumeToken,
    //     uint256 startTime,
    //     uint256 endTime,
    //     uint256 minIncrement
    // )
    //     public
    //     // onlyIfTokenExists(tokenId)
    //     // onlyNFTOwner(tokenId)
    // {
    //     _validateOnlyIfTokenExists(tokenId);
    //     _validateOnlyNFTOwner(tokenId);
    //     _listForAuction(tokenId, amount, consumeToken, startTime, endTime, minIncrement);
    // }

    /**
     * remove NFT from list for sale.
     * @param tokenId NFT tokenId
     */
    function removeFromSale(
        uint256 tokenId
    )
        public 
        // onlyIfTokenExists(tokenId)
        // onlyNFTOwner(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlyNFTOwner(tokenId);
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
        //onlyIfTokenExists(tokenId)
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
        _validateOnlyIfTokenExists(tokenId);
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
        // onlyIfTokenExists(tokenId)
        // onlySale(tokenId)
        // onlySaleForCoins(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlySale(tokenId);
        _validateOnlySaleForCoins(tokenId);
        _validateAuctionActive(tokenId);
        bool success;
        uint256 funds = msg.value;
        require(funds >= tokenData[tokenId].salesData.amount, "NFT: The coins sent are not enough");
        
        
        // if (_isInAuction(tokenId) == 1) {
        //     putInToAuctionList(tokenId, _msgSender(), funds, 0);
        // } else {
            // Refund
            uint256 refund = (funds).sub(tokenData[tokenId].salesData.amount);
            if (refund > 0) {
                (success, ) = (_msgSender()).call{value: refund}("");    
                require(success, "NFT: Failed when send back coins to caller");
            }
            
            _executeTransfer(tokenId, _msgSender(), tokenData[tokenId].salesData.amount, 0);
        // }
       
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
        // onlyIfTokenExists(tokenId)
        // onlySale(tokenId)
        // onlySaleForTokens(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlySale(tokenId);
        _validateOnlySaleForTokens(tokenId);
        _validateAuctionActive(tokenId);
        uint256 needToObtain = tokenData[tokenId].salesData.amount;
        
        IERC20Upgradeable saleToken = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address);
        uint256 minAmount = saleToken.allowance(_msgSender(), address(this)).min(saleToken.balanceOf(_msgSender()));
        
        require (minAmount >= needToObtain, "NFT: The allowance tokens are not enough");
       
        bool success;
        
        success = saleToken.transferFrom(_msgSender(), address(this), needToObtain);
        require(success, MSG_TRANSFERFROM_FAILED);
        
        // if (_isInAuction(tokenId) == 1) {
        //     putInToAuctionList(tokenId, _msgSender(), needToObtain, 1);
            
        // } else {
            _executeTransfer(tokenId, _msgSender(), needToObtain, 1);
        // }
        
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
        // onlyIfTokenExists(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
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
        // onlyIfTokenExists(tokenId)
        // onlyNFTAuthor(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateTokenAuthor(tokenId);
        _validateReduceCommission(reduceCommissionPercent);
        
        tokenData[tokenId].commissions.reduceCommission = reduceCommissionPercent;
    }
    
    function claim(
        uint256 tokenId
    )
        public
        // onlyIfTokenExists(tokenId)
        // onlySale(tokenId)
        // canClaim(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlySale(tokenId);
        _validateCanClaim(tokenId);
        _claim(tokenId);
    }
    
    function acceptLastBid(
        uint256 tokenId
    )
        public
        //onlyIfTokenExists(tokenId)
        //onlySale(tokenId)
        //onlyNFTOwner(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateOnlySale(tokenId);
        _validateOnlyNFTOwner(tokenId);
        
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
        uint256 len = tokenData[tokenId].ownersHistory.length;
        address[] memory ret = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            ret[i] =  tokenData[tokenId].ownersHistory[i];
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
   
    function historyOfSale(
        uint256 tokenId
    ) 
        public 
        view 
        //onlyIfTokenExists(tokenId) 
        returns(SaleInfo[] memory) 
    {
        _validateOnlyIfTokenExists(tokenId);
        return tokenData[tokenId].saleHistory;
    }
    
    function historyOfSale(
        uint256 tokenId, 
        uint256 indexFromEnd
    ) 
        public 
        view 
        //onlyIfTokenExists(tokenId) 
        returns(SaleInfo[] memory) 
    {
        _validateOnlyIfTokenExists(tokenId);
        return _getSaleInfo(tokenId, indexFromEnd);
    }
    
    function _getSaleInfo(uint256 tokenId, uint256 indexFromEnd) internal view returns(SaleInfo[] memory) {
        uint256 len;
        for (uint256 i = 0; i < tokenData[tokenId].saleHistory.length; i++) {
            if (tokenData[tokenId].saleHistory[i].time > indexFromEnd) {
                len = len+1;
            }
        }
        
        SaleInfo[] memory ret = new SaleInfo[](len);
        uint256 j=0;
        for (uint256 i = 0; i < tokenData[tokenId].saleHistory.length; i++) {
            if (tokenData[tokenId].saleHistory[i].time > indexFromEnd) {
                ret[j] = tokenData[tokenId].saleHistory[i];
                j = j.add(1);
            }
        }
        
        return ret;
    }
    

   
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // internal section ///////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // function putInToAuctionList(
    //     uint256 tokenId, 
    //     address sender, 
    //     uint256 amount,
    //     uint256 typeTransfer
    // ) 
    //     internal 
    // {
    //     uint256 len = tokenData[tokenId].salesData.bids.length;
        
    //     uint256 prevBid = (len > 0) ? tokenData[tokenId].salesData.bids[len-1].bid : tokenData[tokenId].salesData.amount;
        
    //     require((prevBid).add(tokenData[tokenId].salesData.minIncrement) <= amount, "bid should be more");
        
    //     // tokenData[tokenId].salesData.bids[len].bidder = sender;
    //     // tokenData[tokenId].salesData.bids[len].bid = amount;
    //     tokenData[tokenId].salesData.bids.push(Bid({bidder: sender, bid: amount}));
        
    //     if (len > 0) {
    //         bool success;
    //         address prevBidder = tokenData[tokenId].salesData.bids[len-1].bidder;
    //         //uint256 prevBid = tokenData[tokenId].salesData.bids[len-1].bid;
            
    //         // refund previous
    //         if (typeTransfer == 0) {
    //             (success, ) = (prevBidder).call{value: prevBid}("");    
    //             require(success, "Failed when send coins");
    //         } else {
                
    //             success = IERC20Upgradeable(tokenData[tokenId].salesData.erc20Address).transfer(prevBidder, prevBid);
    //             // require(success, "Failed when 'transfer' funds to co-author");
    //             // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
    //             require(success);
    //         }
            
    //         emit OutBid(tokenId, amount);
    //     }
        
    // }
    
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
        address author,
        CommissionParams memory commissionParams
    ) 
        internal 
        // canRecord(communitySettings.roleMint) 
        returns(uint256 tokenId)
    {
        _validateCanRecord(communitySettings.roleMint);
        
        require(commissionParams.token != address(0), "NFT: Token address can not be zero");
        require(commissionParams.intervalSeconds > 0, "wrong IntervalSeconds");
        _validateReduceCommission(commissionParams.reduceCommission);
        
        tokenId = _createNFT(URI, author);
        
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

    // function _listForAuction(
    //     uint256 tokenId,
    //     uint256 amount,
    //     address consumeToken,
    //     uint256 startTime,
    //     uint256 endTime,
    //     uint256 minIncrement
    // )
    //     internal
    // {
    //     require(startTime == 0 || startTime >= block.timestamp, 'wrong startTime' );
    //     startTime = (startTime == 0) ? block.timestamp : startTime;
        
    //     require(startTime < endTime || endTime == 0, 'wrong endTime' );
        
    //     __listForSale(tokenId, amount, consumeToken);
        
    //     emit TokenAddedToSale(tokenId, amount, consumeToken);
        
    //     tokenData[tokenId].salesData.startTime = startTime;
    //     tokenData[tokenId].salesData.endTime = endTime;
    //     tokenData[tokenId].salesData.minIncrement = minIncrement;
    //     tokenData[tokenId].salesData.isAuction = true;
        
    //     emit TokenAddedToAuctionSale(tokenId, amount, consumeToken, startTime, endTime, minIncrement);
    // }

    
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
        tokenData[tokenId].ownersHistory.push(to);
        
        if (to != address(0)) {
            totalOwnersList.add(to);
        } 
        
        if ((from != address(0)) && (balanceOf(from) == 1)) {
            totalOwnersList.remove(from);    
        }    
        
        // adding saleHistory 
        tokenData[tokenId].saleHistory.push(SaleInfo(
            //tokenId,
            block.timestamp,
            from,
            to,
            tokenData[tokenId].salesData.amount,
            tokenData[tokenId].salesData.erc20Address,
            tokenData[tokenId].commissions.amount,
            tokenData[tokenId].commissions.token
        ));
        
        super._beforeTokenTransfer(from, to, tokenId);
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
            
            bool success;
            
            if (commissionAmount > 0) {    
                success = IERC20Upgradeable(commissionToken).transfer(author, commissionAmount);
                // require(success, "Failed when 'transfer' funds to author");
                // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
                require(success);
            }
        }
        
    }
    
    // function _isInAuction(
    //     uint256 tokenId
    // ) 
    //     internal 
    //     view 
    //     returns(uint256)
    // {
    //     return tokenData[tokenId].salesData.isAuction == true ? 1 : 0;
    // }
    
    function _validateReduceCommission(
        uint256 _reduceCommission
    ) 
        internal 
        pure
    {
        require(_reduceCommission >= 0 && _reduceCommission <= 10000, "wrong reduceCommission");
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
            require(success, MSG_TRANSFERFROM_FAILED);
            
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
    function _validateCanRecord(
        string memory roleName
    ) 
        private 
        view
    {
        bool s = false;
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

        require(s == true, "Sender has not in accessible List");
    }
    
   
}