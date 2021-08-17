// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib/BokkyPooBahsRedBlackTreeLibrary.sol";
import "./lib/StringUtils.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";


import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./interfaces/INFTAuthorship.sol";
import "./interfaces/INFTSeries.sol";

abstract contract NFTSeriesBase is Initializable, ContextUpgradeable, ERC165Upgradeable, INFTSeries, IERC721MetadataUpgradeable, INFTAuthorship {
    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    using BokkyPooBahsRedBlackTreeLibrary for BokkyPooBahsRedBlackTreeLibrary.Tree;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using StringUtils for *;
    
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to series ID
    //mapping (uint256 => uint256) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    
    //event TokenCreated(address author, uint256 tokenId);
    event TokenSeriesCreated(address author, uint256 fromTokenId, uint256 toTokenId);
    
    CountersUpgradeable.Counter private _tokenIds;
    CountersUpgradeable.Counter private _seriesIds;
    
    mapping(uint256 => Serie) internal series;
    mapping(uint256 => Range) ranges;
    
    struct Serie {
        uint256 from;
        uint256 to;
        string uri;
        BokkyPooBahsRedBlackTreeLibrary.Tree rangesTree;
    }
    
    struct Range {
        uint256 from;
        uint256 to;
        address owner;
        address author;
        CommissionSettings commission;
        SalesData saleData;
        
    }
    
    modifier onlyIfTokenExists(uint256 tokenId) {
        require(_exists(tokenId), "NFTSeriesBase: Nonexistent token");
        _;
    }

    modifier onlyNFTAuthor(uint256 tokenId) {
        (, uint256 rangeId) = _getSeriesIds(tokenId);
        //onlyIfTokenExists(tokenId)
        require(ranges[rangeId].owner != address(0), "NFTSeriesBase: Nonexistent token");
        //onlyNFTAuthor(tokenId)
        require(ranges[rangeId].author == _msgSender(), "NFTAuthorship: sender is not author of token");
        _;
    }

    modifier onlyNFTOwner(uint256 tokenId) {
        (, uint256 rangeId) = _getSeriesIds(tokenId);
        require(ranges[rangeId].owner != address(0), "NFTSeriesBase: Nonexistent token");
        require(ranges[rangeId].owner == _msgSender(), "NFTSeriesBase: Sender is not owner of token");
        _;
    }
    
    /**
     * can see all the tokens that an author has.
     * do not use onchain
     * @param author author's address
     */
    function tokensByAuthor(
        address author
    ) 
        public
        override
        view 
        returns(uint256[] memory) 
        
    {
        uint256 i;
        uint256 j;
        
        uint256 len = 0;
        uint256 next;
        
        for(i=1; i<_seriesIds.current(); i++) {
            
            next = series[i].rangesTree.first();
            
            while (next != 0) {
                
                if (ranges[next].author == author) {
                  len += 1+ranges[next].to - ranges[next].from;
                }
                next = series[i].rangesTree.next(next);
                
            }    
            
        }

        uint256[] memory ret = new uint256[](len);
        uint256 counter = 0;
        for(i=1; i<_seriesIds.current(); i++) {
            
            next = series[i].rangesTree.first();

                while (next != 0) {
                    
                    if (ranges[next].author == author) {
                        for(j = ranges[next].from; j <= ranges[next].to; j++) {
                            ret[counter] = j;
                            counter = counter+1;
                        }
                    }
                    next = series[i].rangesTree.next(next);
                }    
            
            
            
        }
        
        return ret;
        
    }

    /**
     * @param to address
     * @param tokenId token ID
     */
    function transferAuthorship(
        address to, 
        uint256 tokenId
    ) 
        public 
        override
        onlyNFTAuthor(tokenId)
    {
        
        address author = _getAuthor(tokenId);
        require(to != author, "NFTAuthorship: transferAuthorship to current author");
        
        _changeAuthor(to, tokenId);
        
        emit TransferAuthorship(author, to, tokenId);
    }
    
    /**
     * @param tokenId token ID
     */
    function authorOf(
        uint256 tokenId
    )
        public
        override
        onlyIfTokenExists(tokenId)
        view
        returns (address) 
    {
        return _getAuthor(tokenId);
    }
    
    function _getAuthor(uint256 tokenId) private view returns(address) {
        (, uint256 rangeId) = _getSeriesIds(tokenId);
        return ranges[rangeId].author;
    }
    
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(INFTSeries).interfaceId
            || interfaceId == type(IERC721Upgradeable).interfaceId
            || interfaceId == type(IERC721MetadataUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        
        return owner;
    }
    
    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        
        (uint256 serieId,/* uint256 rangeId*/) = _getSeriesIds(tokenId);
        
        // string memory base = _baseURI();
        string memory _tokenURI = series[serieId].uri;
        
        // If there is no base URI, return the token URI.
        // if (bytes(base).length == 0) {
        //     return _tokenURI;
        // }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        // if (bytes(_tokenURI).length > 0) {
        //     return string(abi.encodePacked(base, _tokenURI));
        // }
        
        
        if (bytes(_tokenURI).length > 0) {
            uint256 count = (series[serieId].to).sub((series[serieId].from)).add(1);
            uint256 index = (tokenId).sub(series[serieId].from).add(1);
            
            // ?&t=726&s=4&i=4&c=10
            return string(abi.encodePacked(
            _tokenURI,
            's=', serieId.uintToString(), '&',  //serieId
            'i=', index.uintToString(), '&',  //indexId
            't=', tokenId.uintToString(), '&',  //tokenId
            'c=', count.uintToString()          //count
            ));
        }

        return "";
    }
    
    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = NFTSeriesBase.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
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
        (, uint256 rangeId) = _getSeriesIds(tokenId);

        //initialCommission
        r = ranges[rangeId].commission.amount;
        t = ranges[rangeId].commission.token;
        if (r == 0) {
            
        } else {
            if (ranges[rangeId].commission.multiply == 10000) {
                // left initial commission
            } else {
                
                uint256 intervalsSinceCreate = (block.timestamp.sub(ranges[rangeId].commission.createdTs)).div(ranges[rangeId].commission.intervalSeconds);
                uint256 intervalsSinceLastTransfer = (block.timestamp.sub(ranges[rangeId].commission.lastTransferTs)).div(ranges[rangeId].commission.intervalSeconds);
                
                // (   
                //     initialValue * (multiply ^ intervals) + (intervalsSinceLastTransfer * accrue)
                // ) * (10000 - reduceCommission) / 10000
                
                for(uint256 i = 0; i < intervalsSinceCreate; i++) {
                    r = r.mul(ranges[rangeId].commission.multiply).div(10000);
                    
                }
                
                r = r.add(
                        intervalsSinceLastTransfer.mul(ranges[rangeId].commission.accrue)
                    );
                
            }
            
            r = r.mul(
                        uint256(10000).sub(ranges[rangeId].commission.reduceCommission)
                    ).div(uint256(10000));
                
        }
        
    }

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721Series_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Series_init_unchained(name_, symbol_);
    }

    function __ERC721Series_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        
        _tokenIds.increment();
        _seriesIds.increment();
       // _seriesPartsIds.increment();
    }

    function _ownerOf(uint256 tokenId) internal view returns (address owner) {
        
        (, uint256 rangeId) = _getSeriesIds(tokenId);
        owner = ranges[rangeId].owner;
        
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    
    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = NFTSeriesBase.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    // function _safeMint(address to, string memory URI, uint256 tokenAmount) internal virtual {
    //     _safeMint(to, URI, tokenAmount, "");
    // }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    // function _safeMint(address to, string memory URI, uint256 tokenAmount, bytes memory _data) internal virtual {
    //     _mint(to, URI, tokenAmount);
    //     require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    // }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, string memory URI, uint256 tokenAmount, CommissionParams memory commissionParams) internal virtual returns(uint256 serieId, uint256 rangeId) {
       
        require(to != address(0), "ERC721: mint to the zero address");
        uint256 tokenId = _tokenIds.current();
        uint256 lastTokenId = tokenId+tokenAmount-1;
        
        serieId = _seriesIds.current();
        
        emit TokenSeriesCreated(_msgSender(), tokenId, lastTokenId); 
        
        _tokenIds._value += tokenAmount ;
        
        _balances[to] += tokenAmount;
        
        series[serieId].from = tokenId;
        series[serieId].to = lastTokenId;
        series[serieId].uri = URI;
        
        rangeId = tokenId;
        
        ranges[rangeId].from = tokenId;
        ranges[rangeId].to = lastTokenId;
        ranges[rangeId].owner = to;
        ranges[rangeId].author = to;
        
        ranges[rangeId].commission.token = commissionParams.token;
        ranges[rangeId].commission.amount = commissionParams.amount;
        ranges[rangeId].commission.multiply = (commissionParams.multiply == 0 ? 10000 : commissionParams.multiply);
        ranges[rangeId].commission.accrue = commissionParams.accrue;
        ranges[rangeId].commission.intervalSeconds = commissionParams.intervalSeconds;
        ranges[rangeId].commission.reduceCommission = commissionParams.reduceCommission;
        ranges[rangeId].commission.createdTs = block.timestamp;
        ranges[rangeId].commission.lastTransferTs = block.timestamp;
        //-----------------
        
        series[serieId].rangesTree.insert(rangeId);
        _seriesIds.increment();
        
        return(serieId, rangeId);
    }
    
    function _getSeriesIds(uint256 tokenId) internal view returns(uint256 serieId, uint256 rangeId) {
        
        for(uint256 i=1; i<_seriesIds.current(); i++) {
            
            if (tokenId >= series[i].from && tokenId <= series[i].to) {
                
                uint256 j = series[i].rangesTree.root;
                while (j != 0) {
                    if (tokenId >= ranges[j].from && tokenId <= ranges[j].to) {
                        return (i,j);
                    }
                    if (tokenId < ranges[j].from && tokenId < ranges[j].to) {
                        j = series[i].rangesTree.prev(j);
                    } else if (tokenId > ranges[j].from && tokenId > ranges[j].to) {
                        j = series[i].rangesTree.next(j);
                    }
                }
                
            }
            
           
        }
        return (0,0);
    }
    
    
    function _changeOwner(address newOwner, uint256 tokenId) internal {
        (uint256 serieId, uint256 newRangeId) = splitSeries(tokenId);

        if (newOwner == address(0)) {
            delete ranges[newRangeId];
            series[serieId].rangesTree.remove(newRangeId);
        } else {
            ranges[newRangeId].owner = newOwner;
        }
            
    }
    
    function _changeAuthor(address newAuthor, uint256 tokenId) internal {
        (, uint256 rangeId) = splitSeries(tokenId);

        ranges[rangeId].author = newAuthor;
        
    }
    
    /**
     * method will find serie by tokenId, split it and make another series with single range [tokenId; tokenId] with newOwner
     * 
     */
    function splitSeries(uint256 tokenId) internal returns(uint256 infoId, uint256 newRangeId) {
        
        newRangeId = 0;
        
        (uint256 serieId, uint256 rangeId) = _getSeriesIds(tokenId);
        if (serieId != 0 && rangeId != 0) {
            
            if (ranges[rangeId].from == tokenId && ranges[rangeId].to == tokenId) {
                // no need split it's last part
                newRangeId = rangeId;
                
            } else {
                uint256 tmpRangeId; 
                uint256 tmpRangeId2;
                // create ranges
                if (ranges[rangeId].from == tokenId) {
                    newRangeId = rangeId;
                    // when split (id=4)[4:8] by 4.  i.e. it would be (id=4)[4:4] (id=5)[5:8]
                    
                    //----
                    tmpRangeId = rangeId+1;
                    ranges[tmpRangeId].from = tokenId+1;
                    ranges[tmpRangeId].to = ranges[rangeId].to;
                    ranges[tmpRangeId].owner = ranges[rangeId].owner;
                    ranges[tmpRangeId].author = ranges[rangeId].author;
                    //---
                    ranges[tmpRangeId].commission.token             = ranges[rangeId].commission.token;
                    ranges[tmpRangeId].commission.amount            = ranges[rangeId].commission.amount;
                    ranges[tmpRangeId].commission.multiply          = ranges[rangeId].commission.multiply;
                    ranges[tmpRangeId].commission.accrue            = ranges[rangeId].commission.accrue;
                    ranges[tmpRangeId].commission.intervalSeconds   = ranges[rangeId].commission.intervalSeconds;
                    ranges[tmpRangeId].commission.reduceCommission  = ranges[rangeId].commission.reduceCommission;
                    ranges[tmpRangeId].commission.createdTs         = ranges[rangeId].commission.createdTs;
                    ranges[tmpRangeId].commission.lastTransferTs    = ranges[rangeId].commission.lastTransferTs;
                    //----
                    ranges[newRangeId].from = tokenId;
                    ranges[newRangeId].to = tokenId;
                    
                    series[serieId].rangesTree.insert(tmpRangeId);
                } else {
                    //  when split (id==N)[4:8].  where 4<N<=8
                    
                    newRangeId = tokenId;
                    
                    ranges[newRangeId].from = tokenId;
                    ranges[newRangeId].to = tokenId;
                    ranges[newRangeId].owner = ranges[rangeId].owner;
                    ranges[newRangeId].author = ranges[rangeId].author;
                    //---
                    ranges[newRangeId].commission.token             = ranges[rangeId].commission.token;
                    ranges[newRangeId].commission.amount            = ranges[rangeId].commission.amount;
                    ranges[newRangeId].commission.multiply          = ranges[rangeId].commission.multiply;
                    ranges[newRangeId].commission.accrue            = ranges[rangeId].commission.accrue;
                    ranges[newRangeId].commission.intervalSeconds   = ranges[rangeId].commission.intervalSeconds;
                    ranges[newRangeId].commission.reduceCommission  = ranges[rangeId].commission.reduceCommission;
                    ranges[newRangeId].commission.createdTs         = ranges[rangeId].commission.createdTs;
                    ranges[newRangeId].commission.lastTransferTs    = ranges[rangeId].commission.lastTransferTs;
                    
                    series[serieId].rangesTree.insert(newRangeId);
                    
                    // if N!=8 then create right part
                    if (tokenId != ranges[rangeId].to) {
                        tmpRangeId2 = tokenId+1;
                        ranges[tmpRangeId2].from = tokenId+1;
                        ranges[tmpRangeId2].to = ranges[rangeId].to;
                        ranges[tmpRangeId2].owner = ranges[rangeId].owner;
                        ranges[tmpRangeId2].author = ranges[rangeId].author;
                        //---
                        ranges[tmpRangeId2].commission.token             = ranges[rangeId].commission.token;
                        ranges[tmpRangeId2].commission.amount            = ranges[rangeId].commission.amount;
                        ranges[tmpRangeId2].commission.multiply          = ranges[rangeId].commission.multiply;
                        ranges[tmpRangeId2].commission.accrue            = ranges[rangeId].commission.accrue;
                        ranges[tmpRangeId2].commission.intervalSeconds   = ranges[rangeId].commission.intervalSeconds;
                        ranges[tmpRangeId2].commission.reduceCommission  = ranges[rangeId].commission.reduceCommission;
                        ranges[tmpRangeId2].commission.createdTs         = ranges[rangeId].commission.createdTs;
                        ranges[tmpRangeId2].commission.lastTransferTs    = ranges[rangeId].commission.lastTransferTs;
                        
                        series[serieId].rangesTree.insert(tmpRangeId2);
                    }
                    
                    // finally reduce initial range and make it like "left part"
                    ranges[rangeId].to = tokenId-1;
                }
                
                
            
            }
            
            
           
        }
        
        return (serieId, newRangeId);
    }
    
    
    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = NFTSeriesBase.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        //delete _owners[tokenId];
        _changeOwner(address(0), tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(NFTSeriesBase.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        
        
        _changeOwner(to, tokenId);

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(NFTSeriesBase.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
    uint256[44] private __gap;
}
