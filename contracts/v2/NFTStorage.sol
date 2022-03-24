// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "../lib/StringsW0x.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../interfaces/ICostManager.sol";
import "../interfaces/IFactory.sol";

import "../interfaces/ISafeHook.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";


/**
* @dev
* Storage for any separated parts of NFT: NFTState, NFTView, etc. For all parts storage must be the same. 
* So need to extend by common contrtacts  like Ownable, Reentrancy, ERC721.
* that's why we have to leave stubs. we will implement only in certain contracts. 
* for example "name()", "symbol()" in NFTView.sol and "transfer()", "transferFrom()"  in NFTState.sol
*
* Another way are to decompose Ownable, Reentrancy, ERC721 to single flat contract and implement interface methods only for NFTMain.sol
* Or make like this 
* NFTStorage->NFTBase->NFTStubs->NFTMain, 
* NFTStorage->NFTBase->NFTState
* NFTStorage->NFTBase->NFTView
* 
* Here:
* NFTStorage - only state variables
* NFTBase - common thing that used in all contracts(for state and for view) like _ownerOf(), or can manageSeries,...
* NFTStubs - implemented stubs to make NFTMain are fully ERC721, ERC165, etc
* NFTMain - contract entry point
*/
contract NFTStorage  is 
    ERC165Upgradeable, 
    IERC721MetadataUpgradeable,
    IERC721EnumerableUpgradeable, 
    OwnableUpgradeable, 
    ReentrancyGuardUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;
    using StringsW0x for uint256;
    
    // Token name
    string internal _name;

    // Token symbol
    string internal _symbol;

    // Contract URI
    string internal _contractURI;    
    
    // Address of factory that produced this instance
    address public factory;
    
    // Utility token, if any, to manage during operations
    address public costManager;

    address public trustedForwarder;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balances;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) internal _ownedTokens;

    // Array with all token ids, used for enumeration
    uint256[] internal _allTokens;
    
    mapping(uint64 => EnumerableSetUpgradeable.AddressSet) internal hooks;    // series ID => hooks' addresses

    // Constants for shifts
    uint8 internal constant SERIES_SHIFT_BITS = 192; // 256 - 64
    uint8 internal constant OPERATION_SHIFT_BITS = 240;  // 256 - 16
    
    // Constants representing operations
    uint8 internal constant OPERATION_INITIALIZE = 0x0;
    uint8 internal constant OPERATION_SETMETADATA = 0x1;
    uint8 internal constant OPERATION_SETSERIESINFO = 0x2;
    uint8 internal constant OPERATION_SETOWNERCOMMISSION = 0x3;
    uint8 internal constant OPERATION_SETCOMMISSION = 0x4;
    uint8 internal constant OPERATION_REMOVECOMMISSION = 0x5;
    uint8 internal constant OPERATION_LISTFORSALE = 0x6;
    uint8 internal constant OPERATION_REMOVEFROMSALE = 0x7;
    uint8 internal constant OPERATION_MINTANDDISTRIBUTE = 0x8;
    uint8 internal constant OPERATION_BURN = 0x9;
    uint8 internal constant OPERATION_BUY = 0xA;
    uint8 internal constant OPERATION_TRANSFER = 0xB;

    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint256 internal constant FRACTION = 100000;
    
    string public baseURI;
    string public suffix;
    
//    mapping (uint256 => SaleInfoToken) public salesInfoToken;  // tokenId => SaleInfoToken

    struct FreezeInfo {
        bool exists;
        string baseURI;
        string suffix;
    }

    struct TokenInfo {
        SaleInfoToken salesInfoToken;
        FreezeInfo freezeInfo;
        uint256 hooksCountByToken; // hooks count
        uint256 allTokensIndex; // position in the allTokens array
        uint256 ownedTokensIndex; // index of the owner tokens list
        address owner; //owner address
        address tokenApproval; // approved address
    }

    struct TokenData {
        TokenInfo tokenInfo;
        SeriesInfo seriesInfo;
    }

    mapping (uint256 => TokenInfo) internal tokensInfo;  // tokenId => tokensInfo
    
    mapping (uint64 => SeriesInfo) public seriesInfo;  // seriesId => SeriesInfo

    CommissionInfo public commissionInfo; // Global commission data 

    mapping(uint64 => uint256) public mintedCountBySeries;
    
    struct SaleInfoToken { 
        SaleInfo saleInfo;
        uint256 ownerCommissionValue;
        uint256 authorCommissionValue;
    }
    struct SaleInfo { 
        uint64 onSaleUntil; 
        address currency;
        uint256 price;
    }

    struct SeriesInfo { 
        address payable author;
        uint32 limit;
        SaleInfo saleInfo;
        CommissionData commission;
        string baseURI;
        string suffix;
    }
    
    struct CommissionInfo {
        uint64 maxValue;
        uint64 minValue;
        CommissionData ownerCommission;
    }

    struct CommissionData {
        uint64 value;
        address recipient;
    }

    event SeriesPutOnSale(
        uint64 indexed seriesId, 
        uint256 price, 
        address currency, 
        uint64 onSaleUntil
    );

    event SeriesRemovedFromSale(
        uint64 indexed seriesId
    );

    event TokenRemovedFromSale(
        uint256 indexed tokenId,
        address account
    );

    event TokenPutOnSale(
        uint256 indexed tokenId, 
        address indexed seller, 
        uint256 price, 
        address currency, 
        uint64 onSaleUntil
    );
    
    event TokenBought(
        uint256 indexed tokenId, 
        address indexed seller, 
        address indexed buyer, 
        address currency, 
        uint256 price
    );

    event NewHook(
        uint64 seriesId, 
        address contractAddress
    );
    
    //stubs

    function approve(address/* to*/, uint256/* tokenId*/) public virtual override {revert("stub");}
    function getApproved(uint256/* tokenId*/) public view virtual override returns (address) {revert("stub");}
    function setApprovalForAll(address/* operator*/, bool/* approved*/) public virtual override {revert("stub");}
    function isApprovedForAll(address /*owner*/, address /*operator*/) public view virtual override returns (bool) {revert("stub");}
    function transferFrom(address /*from*/,address /*to*/,uint256 /*tokenId*/) public virtual override {revert("stub");}
    function safeTransferFrom(address /*from*/,address /*to*/,uint256 /*tokenId*/) public virtual override {revert("stub");}
    function safeTransferFrom(address /*from*/,address /*to*/,uint256 /*tokenId*/,bytes memory/* _data*/) public virtual override {revert("stub");}
    function safeTransfer(address /*to*/,uint256 /*tokenId*/) public virtual {revert("stub");}
    function balanceOf(address /*owner*/) public view virtual override returns (uint256) {revert("stub");}
    function ownerOf(uint256 /*tokenId*/) public view virtual override returns (address) {revert("stub");}
    function name() public view virtual override returns (string memory) {revert("stub");}
    function symbol() public view virtual override returns (string memory) {revert("stub");}
    function tokenURI(uint256 /*tokenId*/) public view virtual override returns (string memory) {revert("stub");}
    function tokenOfOwnerByIndex(address /*owner*/, uint256 /*index*/) public view virtual override returns (uint256) {revert("stub");}
    function totalSupply() public view virtual override returns (uint256) {revert("stub");}
    function tokenByIndex(uint256 /*index*/) public view virtual override returns (uint256) {revert("stub");}

    // Base
    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        require(_ownerOf(tokenId) != address(0), "ERC721: approved query for nonexistent token");
        return tokensInfo[tokenId].tokenApproval;
    }
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        address owner = __ownerOf(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function __ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return tokensInfo[tokenId].owner;
    }
    function _isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokensInfo[tokenId].owner != address(0)
            && tokensInfo[tokenId].owner != DEAD_ADDRESS;
    }

    function _baseURIAndSuffix(
        uint256 tokenId
    ) 
        internal 
        view 
        returns(
            string memory baseURI_, 
            string memory suffix_
        ) 
    {
        
        if (tokensInfo[tokenId].freezeInfo.exists) {
            baseURI_ = tokensInfo[tokenId].freezeInfo.baseURI;
            suffix_ = tokensInfo[tokenId].freezeInfo.suffix;
        } else {

            uint64 seriesId = getSeriesId(tokenId);
            baseURI_ = seriesInfo[seriesId].baseURI;
            suffix_ = seriesInfo[seriesId].suffix;

            if (bytes(baseURI_).length == 0) {
                baseURI_ = baseURI;
            }
            if (bytes(suffix_).length == 0) {
                suffix_ = suffix;
            }
        }
    }
    
    function getSeriesId(
        uint256 tokenId
    )
        internal
        pure
        returns(uint64)
    {
        return uint64(tokenId >> SERIES_SHIFT_BITS);
    }

    function _getTokenSaleInfo(uint256 tokenId) 
        internal 
        view 
        returns
        (
            bool isOnSale,
            bool exists, 
            SaleInfo memory data,
            address owner
        ) 
    {
        data = tokensInfo[tokenId].salesInfoToken.saleInfo;

        exists = _exists(tokenId);
        owner = tokensInfo[tokenId].owner;

        if (owner != address(0)) { 
            if (data.onSaleUntil > block.timestamp) {
                isOnSale = true;
            } 
        } else {   
            uint64 seriesId = getSeriesId(tokenId);
            SeriesInfo memory seriesData = seriesInfo[seriesId];
            if (seriesData.saleInfo.onSaleUntil > block.timestamp) {
                isOnSale = true;
                data = seriesData.saleInfo;
                owner = seriesData.author;
            }
        }   
    }
    function _balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
}
