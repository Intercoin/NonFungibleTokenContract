// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "solidity-linked-list/contracts/StructuredLinkedList.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

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
    using StructuredLinkedList for StructuredLinkedList.List;
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    
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
    
    
    CountersUpgradeable.Counter private _tokenIds;
    CountersUpgradeable.Counter private _seriesIds;
    CountersUpgradeable.Counter private _seriesPartsIds;
    
    //StructuredLinkedList.List internal seriesList;
    
    mapping(uint256 => Series) internal series;
    mapping(uint256 => SeriesPart) internal seriesParts;
    struct Series {
        uint256 from;
        uint256 to;
        string uri;
        StructuredLinkedList.List nested;
    }
    struct SeriesPart {
        uint256 from;
        uint256 to;
        address owner;
        address author;
        CommissionSettings commission;
        SalesData saleData;
        // prev?
    }
    
    
    modifier onlyIfTokenExists(uint256 tokenId) {
        require(_exists(tokenId), "ERC721SeriesUpgradeable: Nonexistent token");
        _;
    }
     modifier onlyNFTAuthor(uint256 tokenId) {
        require(_msgSender() == _getAuthor(tokenId), "NFTAuthorship: sender is not author of token");
        _;
    }
     modifier onlyNFTOwner(uint256 tokenId) {
        require(_msgSender() == ownerOf(tokenId), "NFTBase: Sender is not owner of token");
        _;
    }
    
// function test_tokensids() public view returns(uint256) {return _tokenIds.current();}
// function test_seriesids() public view returns(uint256) {return _seriesIds.current();}
// function test_seriesPartids() public view returns(uint256) {return _seriesPartsIds.current();}
// // function test_owners(uint256 p) public view returns(uint256) {return _owners[p];}
// function test_exists(uint256 p) public view returns(bool) {return _exists(p);}
// // function test_existsS(uint256 p) public view returns(address) {return series[_owners[p]].owner;}
// // function test_existsS2(uint256 p) public view returns(Series memory) {return series[_owners[p]];}

// function test_existsS3(uint256 p) public view returns(uint256, uint256) {
    
//     return (_getSeriesIds(p));
    
// }
// function test_existsS4(uint256 p) public view returns(SeriesPart memory) {return seriesParts[p];}


/////////////////////////////////////////////////////////////////////////////////
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
          
        for(i=0; i<_seriesIds.current(); i++) {
            
                (,, next) = series[i].nested.getNode(0);
                
                while (next != 0) {
                    if (seriesParts[next].author == author) {
                       len = 1+seriesParts[next].to - seriesParts[next].from;
                    }
                    (, next) = series[i].nested.getNextNode(next);       
                }

            
        }
        
        uint256[] memory ret = new uint256[](len);
        uint256 counter = 0;
        for(i=0; i<_seriesIds.current(); i++) {
            
                (,, next) = series[i].nested.getNode(0);
                
                while (next != 0) {
                    if (seriesParts[next].author == author) {
                        
                        for(j=seriesParts[next].from; j<=seriesParts[next].to; j++) {
                            ret[counter] = j;
                            counter = counter+1;
                            
                        }
                    }
                    (, next) = series[i].nested.getNextNode(next);       
                }

            
        }
        
        
        return ret;
        
        // TODO 0: need to length of memory array
        // here 2 ways: or specify in params how much to return or make for two attempt: first calculate all tokens, and second create a fixed size memory array and push tokenIds to it
        
        // uint256 len = _authoredTokens[author].length();
        // uint256[] memory ret = new uint256[](len);
        // for (uint256 i = 0; i < len; i++) {
        //     ret[i] = _authoredTokens[author].at(i);
        // }
        // return ret;
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
        onlyIfTokenExists(tokenId)
        onlyNFTAuthor(tokenId)
    {
        
        address author = _getAuthor(tokenId);
        require(to != author, "NFTAuthorship: transferAuthorship to current author");
        
        _changeAuthor(to, tokenId);
        // _setAuthor(tokenId, author, to);
        
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
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        address author = seriesParts[seriesPartId].author;
        return author;
    }
    
  
////////////////////////////////////////////////////////////
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
        
        
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        
        //initialCommission
        r = seriesParts[seriesPartId].commission.amount;
        t = seriesParts[seriesPartId].commission.token;
        if (r == 0) {
            
        } else {
            if (seriesParts[seriesPartId].commission.multiply == 10000) {
                // left initial commission
            } else {
                
                uint256 intervalsSinceCreate = (block.timestamp.sub(seriesParts[seriesPartId].commission.createdTs)).div(seriesParts[seriesPartId].commission.intervalSeconds);
                uint256 intervalsSinceLastTransfer = (block.timestamp.sub(seriesParts[seriesPartId].commission.lastTransferTs)).div(seriesParts[seriesPartId].commission.intervalSeconds);
                
                // (   
                //     initialValue * (multiply ^ intervals) + (intervalsSinceLastTransfer * accrue)
                // ) * (10000 - reduceCommission) / 10000
                
                for(uint256 i = 0; i < intervalsSinceCreate; i++) {
                    r = r.mul(seriesParts[seriesPartId].commission.multiply).div(10000);
                    
                }
                
                r = r.add(
                        intervalsSinceLastTransfer.mul(seriesParts[seriesPartId].commission.accrue)
                    );
                
                r = r.mul(
                        uint256(10000).sub(seriesParts[seriesPartId].commission.reduceCommission)
                    ).div(uint256(10000));
                
            }
        }
        
    }
//////////////////////////////////////////////////



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
        
        // _tokenIds.increment();
        _seriesIds.increment();
        _seriesPartsIds.increment();
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
    
    function _ownerOf(uint256 tokenId) internal view returns (address owner) {
        uint256 seriesPartId;
        (, seriesPartId) = _getSeriesIds(tokenId);
        owner = seriesParts[seriesPartId].owner;
        
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

        uint256 seriesId;
        (seriesId,) = _getSeriesIds(tokenId);
        
        string memory base = _baseURI();
        string memory _tokenURI = series[seriesId].uri;
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return "";
    }


    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
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
// TODO 0: here
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
    function _mint(address to, string memory URI, uint256 tokenAmount, CommissionParams memory commissionParams) internal virtual returns(uint256 seriesId, uint256 seriesPartId) {
       
        require(to != address(0), "ERC721: mint to the zero address");
        uint256 tokenId = _tokenIds.current();
        uint256 lastTokenId = tokenId+tokenAmount-1;
        // 0 +10    0.1.2.3.4.5.6.7.8.9
        
        
        seriesId = _seriesIds.current();
        
        
        for (uint256 i = tokenId; i <= lastTokenId; i++) {
             
            require(!_exists(i), "ERC721: token already minted");

            _beforeTokenTransfer(address(0), to, i);
            
            emit Transfer(address(0), to, i);
            //_owners[i] = seriesId;
            
            
            _tokenIds.increment();
        }
        
        _balances[to] += tokenAmount;
        
        // series[seriesId] = SeriesInfo({
        //     from: tokenId,
        //     to: lastTokenId
        // });
        series[seriesId].from = tokenId;
        series[seriesId].to = lastTokenId;
        series[seriesId].uri = URI;
        
        seriesPartId = _seriesPartsIds.current();
        
        seriesParts[seriesPartId].from = tokenId;
        seriesParts[seriesPartId].to = lastTokenId;
        seriesParts[seriesPartId].owner = to;
        seriesParts[seriesPartId].author = to;
        
        //seriesParts[seriesPartId].commission = commissionParams;
        seriesParts[seriesPartId].commission.token = commissionParams.token;
        seriesParts[seriesPartId].commission.amount = commissionParams.amount;
        seriesParts[seriesPartId].commission.multiply = (commissionParams.multiply == 0 ? 10000 : commissionParams.multiply);
        seriesParts[seriesPartId].commission.accrue = commissionParams.accrue;
        seriesParts[seriesPartId].commission.intervalSeconds = commissionParams.intervalSeconds;
        seriesParts[seriesPartId].commission.reduceCommission = commissionParams.reduceCommission;
        seriesParts[seriesPartId].commission.createdTs = block.timestamp;
        seriesParts[seriesPartId].commission.lastTransferTs = block.timestamp;
        //-----------------
        
        series[seriesId].nested.pushBack(seriesPartId);
        
        _seriesIds.increment();
        _seriesPartsIds.increment();
        
        return(seriesId, seriesPartId);
    }
    
    function _getSeriesIds(uint256 tokenId) public view returns(uint256 infoId, uint256 seriesPartId) {
        //_seriesInfoIds
        for(uint256 i=0; i<_seriesIds.current(); i++) {
            
            if (tokenId >= series[i].from && tokenId <= series[i].to) {
                uint256 next;

                (,, next) = series[i].nested.getNode(0);
                
                while (next != 0) {
                    // TODO 0: can be modify code and skip unnecessary iteration
                    // means we useing linked list so we can skip and breal cycle if tokenId out of range[from;to] from left. means tokenId<from && tokenId<to
                    
                    // TODO 0: addiiotnally we can improve logic.
                    // we can decide from which side start to find. i.e. tokenId = 480 and range [1;500] then we start to find from the end of linkedList
                    if (tokenId >= seriesParts[next].from && tokenId <= seriesParts[next].to) {
                        return (i,next);
                    }
                    (, next) = series[i].nested.getNextNode(next);       
                }

            }
        }
        return (0,0);
    }
    
    
    function _changeOwner(address newOwner, uint256 tokenId) internal {
        uint256 seriesId;
        uint256 newSeriesPartsId;
        (seriesId, newSeriesPartsId) = splitSeries(tokenId);

        if (newOwner == address(0)) {
            delete seriesParts[newSeriesPartsId];
            series[seriesId].nested.remove(newSeriesPartsId);
        } else {
            seriesParts[newSeriesPartsId].owner = newOwner;
        }
            
    }
    
    function _changeAuthor(address newAuthor, uint256 tokenId) internal {
        uint256 seriesId;
        uint256 newSeriesPartsId;
        (seriesId, newSeriesPartsId) = splitSeries(tokenId);

        seriesParts[newSeriesPartsId].author = newAuthor;
        
    }
    
    /**
     * method will find serie by tokenId, split it and make another series with single range [tokenId; tokenId] with newOwner
     * 
     */
    function splitSeries(uint256 tokenId) internal returns(uint256 infoId, uint256 newSeriesPartsId) {
        infoId = 0;
        newSeriesPartsId = 0;
        
        uint256 seriesPartId;
        (infoId, seriesPartId) = _getSeriesIds(tokenId);
        if (infoId != 0 && seriesPartId != 0) {
            
            if (seriesParts[seriesPartId].from == tokenId && seriesParts[seriesPartId].to == tokenId) {
                // no need split it's last part
                newSeriesPartsId = seriesPartId;
                
            } else {
                // create part of series
            
                newSeriesPartsId = _seriesPartsIds.current();
                
                //-------------------------------
                // seriesParts[newSeriesPartsId] = seriesParts[seriesPartId];
                // seriesParts[newSeriesPartsId].from = tokenId;
                // seriesParts[newSeriesPartsId].to = tokenId;
                //-------------------------------
                
                seriesParts[newSeriesPartsId].from = tokenId;
                seriesParts[newSeriesPartsId].to = tokenId;
                seriesParts[newSeriesPartsId].owner = seriesParts[seriesPartId].owner;
                seriesParts[newSeriesPartsId].author =seriesParts[seriesPartId]. author;
                //---
                seriesParts[newSeriesPartsId].commission.token = seriesParts[seriesPartId].commission.token;
                seriesParts[newSeriesPartsId].commission.amount = seriesParts[seriesPartId].commission.amount;
                seriesParts[newSeriesPartsId].commission.multiply = seriesParts[seriesPartId].commission.multiply;
                seriesParts[newSeriesPartsId].commission.accrue = seriesParts[seriesPartId].commission.accrue;
                seriesParts[newSeriesPartsId].commission.intervalSeconds = seriesParts[seriesPartId].commission.intervalSeconds;
                seriesParts[newSeriesPartsId].commission.reduceCommission = seriesParts[seriesPartId].commission.reduceCommission;
                seriesParts[newSeriesPartsId].commission.createdTs = seriesParts[seriesPartId].commission.createdTs;
                seriesParts[newSeriesPartsId].commission.lastTransferTs = seriesParts[seriesPartId].commission.lastTransferTs;
                //-------------------------------
    
                //series[infoId].nested.insertAfter(seriesPartId, newSeriesPartsId);
                _seriesPartsIds.increment();
            
            
                if (seriesParts[seriesPartId].from == tokenId) {
                    //first in range. remove from left 
                    seriesParts[seriesPartId].from += 1;
                    
                    series[infoId].nested.insertBefore(seriesPartId, newSeriesPartsId);
                    
                } else if (seriesParts[seriesPartId].to == tokenId) {
                    //last in range. remove from right 
                    seriesParts[seriesPartId].to -= 1;
                    series[infoId].nested.insertAfter(seriesPartId, newSeriesPartsId);
                } else {
                    
                    // split on two pieces
                    // initial serie left the same id but reduce from right side
                    // creating new part right side that left and link in list
                    
                    seriesParts[seriesPartId].to = tokenId-1;
                    // -----
                    
                    uint256 tmpSeriesPartsId = _seriesPartsIds.current();
                    
                    //-------------------------------
                    //seriesParts[tmpSeriesPartsId] = seriesParts[seriesPartId];
                    //-------------------------------
                    seriesParts[tmpSeriesPartsId].from = tokenId;
                    seriesParts[tmpSeriesPartsId].to = tokenId;
                    seriesParts[tmpSeriesPartsId].owner = seriesParts[seriesPartId].owner;
                    seriesParts[tmpSeriesPartsId].author =seriesParts[seriesPartId]. author;
                    //---
                    seriesParts[tmpSeriesPartsId].commission.token = seriesParts[seriesPartId].commission.token;
                    seriesParts[tmpSeriesPartsId].commission.amount = seriesParts[seriesPartId].commission.amount;
                    seriesParts[tmpSeriesPartsId].commission.multiply = seriesParts[seriesPartId].commission.multiply;
                    seriesParts[tmpSeriesPartsId].commission.accrue = seriesParts[seriesPartId].commission.accrue;
                    seriesParts[tmpSeriesPartsId].commission.intervalSeconds = seriesParts[seriesPartId].commission.intervalSeconds;
                    seriesParts[tmpSeriesPartsId].commission.reduceCommission = seriesParts[seriesPartId].commission.reduceCommission;
                    seriesParts[tmpSeriesPartsId].commission.createdTs = seriesParts[seriesPartId].commission.createdTs;
                seriesParts[newSeriesPartsId].commission.lastTransferTs = seriesParts[seriesPartId].commission.lastTransferTs;
                //-------------------------------
                    
                    seriesParts[seriesPartId].to = tokenId-1;
                    seriesParts[tmpSeriesPartsId].from = tokenId+1;
                    
                    series[infoId].nested.insertAfter(seriesPartId, tmpSeriesPartsId);
                    
                    _seriesPartsIds.increment();
                
                    series[infoId].nested.insertAfter(seriesPartId, newSeriesPartsId);
                }
            
            }
            
            
           
        }
        
        return (infoId, newSeriesPartsId);
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
