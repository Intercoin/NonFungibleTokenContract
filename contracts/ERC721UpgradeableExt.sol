// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./lib/StringsW0x.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./interfaces/ICostManager.sol";
import "./interfaces/IFactory.sol";

import "./interfaces/ISafeHook.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

abstract contract ERC721UpgradeableExt is 
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
    string private _name;

    // Token symbol
    string private _symbol;

    // Contract URI
    string internal _contractURI;    
    
    // Address of factory that produced this instance
    address public factory;
    
    // Utility token, if any, to manage during operations
    address public costManager;

    address public trustedForwarder;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;
    
    mapping(uint256 => EnumerableSetUpgradeable.AddressSet) internal hooks;    // series ID => hooks' addresses

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
    mapping (uint256 => TokenInfo) public tokenInfo;  // tokenId => tokenInfo
    
    mapping (uint256 => SeriesInfo) public seriesInfo;  // seriesId => SeriesInfo

    CommissionInfo public commissionInfo; // Global commission data 

    mapping(uint256 => uint256) public mintedCountBySeries;
    
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
        uint256 seriesId, 
        address contractAddress
    );
    
    /********************************************************************
    ****** external section *********************************************
    *********************************************************************/
    
    /**
    * @dev sets the default baseURI for the whole contract
    * @param baseURI_ the prefix to prepend to URIs
    */
    function setBaseURI(
        string calldata baseURI_
    ) 
        onlyOwner
        external
    {
    
        baseURI = baseURI_;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x100,
            0
        );
    }
    
    /**
    * @dev sets the default URI suffix for the whole contract
    * @param suffix_ the suffix to append to URIs
    */
    function setSuffix(
        string calldata suffix_
    ) 
        onlyOwner
        external
    {
        suffix = suffix_;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x010,
            0
        );
    }

     /**
    * @dev sets contract URI. 
    * @param newContractURI new contract URI
    */
    function setContractURI(string memory newContractURI) external onlyOwner {
        _contractURI = newContractURI;
        _accountForOperation(
            OPERATION_SETMETADATA << OPERATION_SHIFT_BITS,
            0x001,
            0
        );
    }

    /**
    * @dev sets information for series with 'seriesId'. 
    * @param seriesId series ID
    * @param info new info to set
    */
    function setSeriesInfo(
        uint64 seriesId, 
        SeriesInfo memory info 
    ) 
        external
    {
        _requireCanManageSeries(seriesId);
        if (info.saleInfo.onSaleUntil > seriesInfo[seriesId].saleInfo.onSaleUntil && 
            info.saleInfo.onSaleUntil > block.timestamp
        ) {
            emit SeriesPutOnSale(
                seriesId, 
                info.saleInfo.price, 
                info.saleInfo.currency, 
                info.saleInfo.onSaleUntil
            );
        } else if (info.saleInfo.onSaleUntil <= block.timestamp ) {
            emit SeriesRemovedFromSale(seriesId);
        }
        
        seriesInfo[seriesId] = info;

        _accountForOperation(
            (OPERATION_SETSERIESINFO << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(info.saleInfo.currency)),
            info.saleInfo.price
        );
        
    }

    /**
    * set commission paid to contract owner
    * @param commission new commission info
    */
    function setOwnerCommission(
        CommissionInfo memory commission
    ) 
        external 
        onlyOwner 
    {
        commissionInfo = commission;

        _accountForOperation(
            OPERATION_SETOWNERCOMMISSION << OPERATION_SHIFT_BITS,
            uint256(uint160(commission.ownerCommission.recipient)),
            commission.ownerCommission.value
        );

    }

    /**
    * set commission for series
    * @param commissionData new commission data
    */
    function setCommission(
        uint64 seriesId, 
        CommissionData memory commissionData
    ) 
        external 
    {
        _requireCanManageSeries(seriesId);
        require(
            (
                commissionData.value <= commissionInfo.maxValue &&
                commissionData.value >= commissionInfo.minValue &&
                commissionData.value + commissionInfo.ownerCommission.value < FRACTION
            ),
            "COMMISSION_INVALID"
        );
        require(commissionData.recipient != address(0), "RECIPIENT_INVALID");
        seriesInfo[seriesId].commission = commissionData;
        
        _accountForOperation(
            (OPERATION_SETCOMMISSION << OPERATION_SHIFT_BITS) | seriesId,
            commissionData.value,
            uint256(uint160(commissionData.recipient))
        );
        
    }

    /**
    * clear commission for series
    * @param seriesId seriesId
    */
    function removeCommission(
        uint64 seriesId
    ) 
        external 
    {
        _requireCanManageSeries(seriesId);
        delete seriesInfo[seriesId].commission;
        
        _accountForOperation(
            (OPERATION_REMOVECOMMISSION << OPERATION_SHIFT_BITS) | seriesId,
            0,
            0
        );
        
    }

    /**
    * @dev lists on sale NFT with defined token ID with specified terms of sale
    * @param tokenId token ID
    * @param price price for sale 
    * @param currency currency of sale 
    * @param duration duration of sale 
    */
    function listForSale(
        uint256 tokenId,
        uint256 price,
        address currency,
        uint64 duration
    )
        external 
    {
        (bool success, /*bool isExists*/, /*SaleInfo memory data*/, /*address owner*/) = getTokenSaleInfo(tokenId);
        
        _requireCanManageToken(tokenId);
        require(!success, "already on sale");
        require(duration > 0, "invalid duration");

        uint64 seriesId = getSeriesId(tokenId);
        SaleInfo memory newSaleInfo = SaleInfo({
            onSaleUntil: uint64(block.timestamp) + duration,
            currency: currency,
            price: price
        });
        SaleInfoToken memory saleInfoToken = SaleInfoToken({
            saleInfo: newSaleInfo,
            ownerCommissionValue: commissionInfo.ownerCommission.value,
            authorCommissionValue: seriesInfo[seriesId].commission.value
        });
        _setSaleInfo(tokenId, saleInfoToken);

        emit TokenPutOnSale(
            tokenId, 
            _msgSender(), 
            newSaleInfo.price, 
            newSaleInfo.currency, 
            newSaleInfo.onSaleUntil
        );
        
        _accountForOperation(
            (OPERATION_LISTFORSALE << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(currency)),
            price
        );
    }
    
    /**
    * @dev removes from sale NFT with defined token ID
    * @param tokenId token ID
    */
    function removeFromSale(
        uint256 tokenId
    )
        external 
    {
        (bool success, /*bool isExists*/, SaleInfo memory data, /*address owner*/) = getTokenSaleInfo(tokenId);
        require(success, "token not on sale");
        _requireCanManageToken(tokenId);
        clearOnSaleUntil(tokenId);

        emit TokenRemovedFromSale(tokenId, _msgSender());
        
        uint64 seriesId = getSeriesId(tokenId);
        _accountForOperation(
            (OPERATION_REMOVEFROMSALE << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(data.currency)),
            data.price
        );
    }

    /**
    * @dev returns the list of all NFTs owned by 'account' with limit
    * @param account address of account
    */
    function tokensByOwner(
        address account,
        uint32 limit
    ) 
        external
        view
        returns (uint256[] memory ret)
    {
        return _tokensByOwner(account, limit);
    }

    /**
    * @dev mints and distributes NFTs with specified IDs
    * to specified addresses
    * @param tokenIds list of NFT IDs t obe minted
    * @param addresses list of receiver addresses
    */
    function mintAndDistribute(
        uint256[] memory tokenIds, 
        address[] memory addresses
    )
        external 
    {
        uint256 len = addresses.length;
        require(tokenIds.length == len, "lengths should be the same");
        
        for(uint256 i = 0; i < len; i++) {
            _requireCanManageSeries(getSeriesId(tokenIds[i]));
            _mint(addresses[i], tokenIds[i]);
        }
        
        _accountForOperation(
            OPERATION_MINTANDDISTRIBUTE << OPERATION_SHIFT_BITS,
            len,
            0
        );
    }
    
    /** 
    * @dev sets the utility token
    * @param costManager_ new address of utility token, or 0
    */
    function overrideCostManager(address costManager_) external {
        // require factory owner or operator
        // otherwise needed deployer(!!not contract owner) in cases if was deployed manually
        require (
            (factory.isContract()) 
                ?
                    IFactory(factory).canOverrideCostManager(_msgSender(), address(this))
                :
                    factory == _msgSender()
            ,
            "cannot override"
        );
        costManager = costManager_;
    }

    /**
    * @dev returns the list of hooks for series with `seriesId`
    * @param seriesId series ID
    */
    function getHookList(
        uint256 seriesId
    ) 
        external 
        view 
        returns(address[] memory) 
    {
        uint256 len = hooksCount(seriesId);
        address[] memory allHooks = new address[](len);
        for (uint256 i = 0; i < hooksCount(seriesId); i++) {
            allHooks[i] = hooks[seriesId].at(i);
        }
        return allHooks;
    }

    /********************************************************************
    ****** public section ***********************************************
    *********************************************************************/
    /**
    * @dev tells the caller whether they can set info for a series,
    * manage amount of commissions for the series,
    * mint and distribute tokens from it, etc.
    * @param seriesId the id of the series being asked about
    */
    function canManageSeries(uint64 seriesId) public view returns (bool) {
        return _canManageSeries(seriesId);
    }

    /**
    * @dev tells the caller whether they can transfer an existing token,
    * list it for sale and remove it from sale.
    * Tokens can be managed by their owner
    * or approved accounts via {approve} or {setApprovalForAll}.
    * @param tokenId the id of the tokens being asked about
    */
    function canManageToken(uint256 tokenId) public view returns (bool) {
        return _canManageToken(tokenId);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function tokenExists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }
    
    /**
    * @dev buys NFT for native coin with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param price amount of specified native coin to pay
    * @param safe use safeMint and safeTransfer or not, 
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        public 
        payable 
        nonReentrant 
    {
        uint64 seriesId = getSeriesId(tokenId);

        validateHookCount(seriesId, hookCount);

        (bool success, bool exists, SaleInfo memory data, address beneficiary) = getTokenSaleInfo(tokenId);

        _commissions_payment(tokenId, address(0), true, price, success, data, beneficiary);

        _buy(tokenId, exists, data, beneficiary, safe);
        
        
        _accountForOperation(
            (OPERATION_BUY << OPERATION_SHIFT_BITS) | seriesId, 
            0,
            price
        );
    }

    
    /**
    * @dev buys NFT for specified currency with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param currency address of token to pay with
    * @param price amount of specified token to pay
    * @param safe use safeMint and safeTransfer or not
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        address currency, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        public 
        nonReentrant 
    {
        uint64 seriesId = getSeriesId(tokenId);

        validateHookCount(seriesId, hookCount);    

        (bool success, bool exists, SaleInfo memory data, address owner) = getTokenSaleInfo(tokenId);

        _commissions_payment(tokenId, currency, false, price, success, data, owner);
        
        _buy(tokenId, exists, data, owner, safe);
        
        _accountForOperation(
            (OPERATION_BUY << OPERATION_SHIFT_BITS) | seriesId,
            uint256(uint160(currency)),
            price
        );
    }

    
    /**
    * @dev returns contract URI. 
    */
    function contractURI() public view returns(string memory){
        return _contractURI;
    }

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            interfaceId == type(IERC721EnumerableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev Returns the token collection name.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /** 
    * @dev sets name and symbol for contract
    * @param newName new name 
    * @param newSymbol new symbol 
    */
    function setNameAndSymbol(
        string memory newName, 
        string memory newSymbol
    ) 
        public 
        onlyOwner 
    {
        _setNameAndSymbol(newName, newSymbol);
    }
    
  
    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(
        uint256 tokenId
    ) 
        public 
        view 
        virtual 
        override
        returns (string memory) 
    {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        string memory _tokenIdHexString = tokenId.toHexString();

        string memory baseURI_;
        string memory suffix_;
        (baseURI_, suffix_) = _baseURIAndSuffix(tokenId);

        // If all are set, concatenate
        if (bytes(_tokenIdHexString).length > 0) {
            return string(abi.encodePacked(baseURI_, _tokenIdHexString, suffix_));
        }
        return "";
    }

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        address ms = _msgSender();
        require(
            ms == owner || isApprovedForAll(owner, ms),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(ownerOf(tokenId) != address(0), "ERC721: approved query for nonexistent token");

        return tokenInfo[tokenId].tokenApproval;
    }

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        _requireCanManageToken(tokenId);

        _transfer(from, to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _requireCanManageToken(tokenId);
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Transfers `tokenId` token from sender to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by sender.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address to,
        uint256 tokenId
    ) public virtual {
        _requireCanManageToken(tokenId);
        _transfer(_msgSender(), to, tokenId);
    }

    /**
     * @dev Safely transfers `tokenId` token from sender to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by sender.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransfer(
        address to,
        uint256 tokenId
    ) public virtual {
        _requireCanManageToken(tokenId);
        _safeTransfer(_msgSender(), to, tokenId, "");
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public virtual {
        //solhint-disable-next-line max-line-length
        _requireCanManageToken(tokenId);
        _burn(tokenId);
        
        _accountForOperation(
            OPERATION_BURN << OPERATION_SHIFT_BITS,
            tokenId,
            0
        );
    }

    /**
    * @dev returns if token is on sale or not, 
    * whether it exists or not,
    * as well as data about the sale and its owner
    * @param tokenId token ID 
    */
    function getTokenSaleInfo(uint256 tokenId) 
        public 
        view 
        returns
        (
            bool isOnSale,
            bool exists, 
            SaleInfo memory data,
            address owner
        ) 
    {
        data = tokenInfo[tokenId].salesInfoToken.saleInfo;

        exists = _exists(tokenId);
        owner = tokenInfo[tokenId].owner;

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

   /**
    * @dev the owner should be absolutely sure they trust the trustedForwarder
    * @param trustedForwarder_ must be a smart contract that was audited
    */
    function setTrustedForwarder(
        address trustedForwarder_
    )
        onlyOwner 
        public 
    {
        _setTrustedForwarder(trustedForwarder_);
    }

    /**
    * @dev link safeHook contract to certain series
    * @param seriesId series ID
    * @param contractAddress address of SafeHook contract
    */
    function pushTokenTransferHook(
        uint256 seriesId, 
        address contractAddress
    )
        public 
        onlyOwner
    {

        try ISafeHook(contractAddress).supportsInterface(type(ISafeHook).interfaceId) returns (bool success) {
            if (success) {
                hooks[seriesId].add(contractAddress);
            } else {
                revert("wrong interface");
            }
        } catch {
            revert("wrong interface");
        }

        emit NewHook(seriesId, contractAddress);

    }

    function freeze(uint256 tokenId) public {
        string memory baseURI_;
        string memory suffix_;
        (baseURI_, suffix_) = _baseURIAndSuffix(tokenId);
        _freeze(tokenId, baseURI, suffix);
    }

    function freeze(uint256 tokenId, string memory baseURI_, string memory suffix_) public 
    {
        _freeze(tokenId, baseURI_, suffix_);
    }
    function unFreeze(uint256 tokenId) public {}
      
    /********************************************************************
    ****** internal section *********************************************
    *********************************************************************/

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
    

    function _freeze(uint256 tokenId, string memory baseURI_, string memory suffix_) internal 
    {
        require(ownerOf(tokenId) == _msgSender(), "token isn't owned by sender");
        tokenInfo[tokenId].freezeInfo.exists = true;
        tokenInfo[tokenId].freezeInfo.baseURI = baseURI_;
        tokenInfo[tokenId].freezeInfo.suffix = suffix_;
        
    }
    function _msgSender(
    ) 
        internal 
        view 
        override
        returns (address signer) 
    {
        signer = msg.sender;
        if (msg.data.length >= 20 && trustedForwarder == signer) {
            assembly {
                signer := shr(96,calldataload(sub(calldatasize(),20)))
            }
        }    
    }

    function _setTrustedForwarder(
        address trustedForwarder_
    )
        internal 
    {
        trustedForwarder = trustedForwarder_;
    }

    function _transferOwnership(
        address newOwner
    ) 
        internal 
        virtual 
        override
    {
        super._transferOwnership(newOwner);
        _setTrustedForwarder(address(0));
    }

    function _buy(
        uint256 tokenId, 
        bool exists, 
        SaleInfo memory data, 
        address owner, 
        bool safe
    ) 
        internal 
        virtual 
    {
        _storeHookCount(tokenId);

        address ms = _msgSender();
        if (exists) {
            if (safe) {
                _safeTransfer(owner, ms, tokenId, new bytes(0));
            } else {
                _transfer(owner, ms, tokenId);
            }
            emit TokenBought(
                tokenId, 
                owner, 
                ms, 
                data.currency, 
                data.price
            );
        } else {

            if (safe) {
                _safeMint(ms, tokenId);
            } else {
                _mint(ms, tokenId);
            }
            emit Transfer(owner, ms, tokenId);
            emit TokenBought(
                tokenId, 
                owner, 
                ms, 
                data.currency, 
                data.price
            );
        }
         
    }

    
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(
        string memory name_, 
        string memory symbol_, 
        address costManager_, 
        address producedBy_
    ) 
        internal 
        initializer 
    {
        __Context_init();
        __ERC165_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        _setNameAndSymbol(name_, symbol_);
        costManager = costManager_;
        factory = _msgSender();
        
        _accountForOperation(
            OPERATION_INITIALIZE << OPERATION_SHIFT_BITS,
            uint256(uint160(producedBy_)),
            0
        );
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
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "recipient must implement ERC721Receiver interface");
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return tokenInfo[tokenId].owner;
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
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

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
     * Emits a {Transfer} event. if flag `skipEvent` is false
     */
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
    {
        _storeHookCount(tokenId);

        require(to != address(0), "can't mint to the zero address");
        require(tokenInfo[tokenId].owner == address(0), "token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        tokenInfo[tokenId].owner = to;

        uint64 seriesId = getSeriesId(tokenId);
        mintedCountBySeries[seriesId] += 1;

        if (seriesInfo[seriesId].limit != 0) {
            require(
                mintedCountBySeries[seriesId] <= seriesInfo[seriesId].limit, 
                "series token limit exceeded"
            );
        }
        

        emit Transfer(address(0), to, tokenId);
        
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
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        
        _balances[DEAD_ADDRESS] += 1;
        tokenInfo[tokenId].owner = DEAD_ADDRESS;
        clearOnSaleUntil(tokenId);
        emit Transfer(owner, DEAD_ADDRESS, tokenId);

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
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "token isn't owned by from address");
        require(to != address(0), "can't transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        tokenInfo[tokenId].owner = to;

        clearOnSaleUntil(tokenId);

        emit Transfer(from, to, tokenId);
        
        _accountForOperation(
            (OPERATION_TRANSFER << OPERATION_SHIFT_BITS) | getSeriesId(tokenId),
            uint256(uint160(from)),
            uint256(uint160(to))
        );
        
    }
    
    /**
    * @dev sets sale info for the NFT with 'tokenId'
    * @param tokenId token ID
    * @param info information about sale 
    */
    function _setSaleInfo(
        uint256 tokenId, 
        SaleInfoToken memory info 
    ) 
        internal 
    {
        //salesInfoToken[tokenId] = info;
        tokenInfo[tokenId].salesInfoToken = info;
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        tokenInfo[tokenId].tokenApproval = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
    /**
    * @param account account
    * @param limit limit
    */
    function _tokensByOwner(
        address account,
        uint32 limit
    ) 
        internal
        view
        returns (uint256[] memory array)
    {
        uint256 len = balanceOf(account);
        if (len > 0) {
            len = (limit != 0 && limit < len) ? limit : len;
            array = new uint256[](len);
            for (uint256 i = 0; i < len; i++) {
                array[i] = _ownedTokens[account][i];
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
    
    /** 
    * @dev sets name and symbol for contract
    * @param newName new name 
    * @param newSymbol new symbol 
    */
    function _setNameAndSymbol(
        string memory newName, 
        string memory newSymbol
    ) 
        internal 
    {
        _name = newName;
        _symbol = newSymbol;
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
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        //safe hook
        uint256 seriesId = tokenId >> SERIES_SHIFT_BITS;
        for (uint256 i = 0; i < tokenInfo[tokenId].hooksCountByToken; i++) {
            try ISafeHook(hooks[seriesId].at(i)).executeHook(from, to, tokenId)
			returns (bool success) {
                if (!success) {
                    revert("Transfer Not Authorized");
                }
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
	            revert(reason);
	        } catch {
                revert("Transfer Not Authorized");
            }
        }
        ////
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function clearOnSaleUntil(uint256 tokenId) internal {
        if (tokenInfo[tokenId].salesInfoToken.saleInfo.onSaleUntil > 0 ) tokenInfo[tokenId].salesInfoToken.saleInfo.onSaleUntil = 0;
    }

    function _requireCanManageSeries(uint64 seriesId) internal view virtual {
        require(_canManageSeries(seriesId), "you can't manage this series");
    }
             
    function _requireCanManageToken(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "token doesn't exist");
        require(_canManageToken(tokenId), "you can't manage this token");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenInfo[tokenId].owner != address(0)
            && tokenInfo[tokenId].owner != DEAD_ADDRESS;
    }

    function _canManageToken(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) == _msgSender()
            || getApproved(tokenId) == _msgSender()
            || isApprovedForAll(_ownerOf(tokenId), _msgSender());
    }

    function _canManageSeries(uint64 seriesId) internal view returns(bool) {
        return owner() == _msgSender() || seriesInfo[seriesId].author == _msgSender();
    }
    
    /**
    * @dev returns count of hooks for series with `seriesId`
    * @param seriesId series ID
    */
    function hooksCount(
        uint256 seriesId
    ) 
        internal 
        view 
        returns(uint256) 
    {
        return hooks[seriesId].length();
    }

    /**
    * @dev validates hook count
    * @param seriesId series ID
    * @param hookCount hook count
    */
    function validateHookCount(
        uint64 seriesId,
        uint256 hookCount
    ) 
        internal 
        view 
    {
        require(hookCount == hooksCount(seriesId), "wrong hookCount");
    }

    /** 
    * @dev used to storage hooksCountByToken at this moment
    */
    function _storeHookCount(
        uint256 tokenId
    )
        internal
    {
        tokenInfo[tokenId].hooksCountByToken = hooks[tokenId >> SERIES_SHIFT_BITS].length();
    }

    /**
    * payment while buying. combined version for payable and for tokens
    */
    function _commissions_payment(
        uint256 tokenId,
        address currency,
        bool isPayable,
        uint256 price, 
        bool success,
        SaleInfo memory data, 
        address beneficiary
    )
        internal
    {
        require(success, "token is not on sale");

        require(
            (isPayable && address(0) == data.currency) ||
            (!isPayable && currency == data.currency),
            "wrong currency for sale"
        );

        uint256 amount = (isPayable ? msg.value : IERC20Upgradeable(data.currency).allowance(_msgSender(), address(this)));
        require(amount >= data.price && price >= data.price, "insufficient amount sent");

        uint256 left = data.price;
        (address[2] memory addresses, uint256[2] memory values, uint256 length) = calculateCommission(tokenId, data.price);

        // commissions payment
        bool transferSuccess;
        for(uint256 i = 0; i < length; i++) {
            if (isPayable) {
                (transferSuccess, ) = addresses[i].call{gas: 3000, value: values[i]}(new bytes(0));
                require(transferSuccess, "TRANSFER_COMMISSION_FAILED");
            } else {
                IERC20Upgradeable(data.currency).transferFrom(_msgSender(), addresses[i], values[i]);
            }
            left -= values[i];
        }

        // payment to beneficiary and refund
        if (isPayable) {
            (transferSuccess, ) = beneficiary.call{gas: 3000, value: left}(new bytes(0));
            require(transferSuccess, "TRANSFER_TO_OWNER_FAILED");

            // try to refund
            if (amount > data.price) {
                // todo 0: if  EIP-2771 using. to whom refund will be send? msg.sender or trusted forwarder
                (transferSuccess, ) = msg.sender.call{gas: 3000, value: (amount - data.price)}(new bytes(0));
                require(transferSuccess, "REFUND_FAILED");
            }

        } else {
            IERC20Upgradeable(data.currency).transferFrom(_msgSender(), beneficiary, left);
        }

    }

    /**
    * @dev calculate commission for `tokenId`
    *  if param exists equal true, then token doesn't exists yet. 
    *  otherwise we should use snapshot parameters: ownerCommission/authorCommission, that hold during listForSale.
    *  used to prevent increasing commissions
    * @param tokenId token ID to calculate commission
    * @param price amount of specified token to pay 
    */
    function calculateCommission(
        uint256 tokenId,
        uint256 price
    ) 
        internal 
        view 
        returns(
            address[2] memory addresses, 
            uint256[2] memory values,
            uint256 length
        ) 
    {
        uint64 seriesId = getSeriesId(tokenId);
        length = 0;
        uint256 sum;
        // contract owner commission
        if (commissionInfo.ownerCommission.recipient != address(0)) {
            uint256 oc = tokenInfo[tokenId].salesInfoToken.ownerCommissionValue;
            if (commissionInfo.ownerCommission.value < oc)
                oc = commissionInfo.ownerCommission.value;
            if (oc != 0) {
                addresses[length] = commissionInfo.ownerCommission.recipient;
                sum += oc;
                values[length] = oc * price / FRACTION;
                length++;
            }
        }

        // author commission
        if (seriesInfo[seriesId].commission.recipient != address(0)) {
            uint256 ac = tokenInfo[tokenId].salesInfoToken.authorCommissionValue;
            if (seriesInfo[seriesId].commission.value < ac) 
                ac = seriesInfo[seriesId].commission.value;
            if (ac != 0) {
                addresses[length] = seriesInfo[seriesId].commission.recipient;
                sum += ac;
                values[length] = ac * price / FRACTION;
                length++;
            }
        }

        require(sum < FRACTION, "invalid commission");

    }


    /********************************************************************
    ****** private section **********************************************
    *********************************************************************/

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
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
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
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        tokenInfo[tokenId].ownedTokensIndex = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        tokenInfo[tokenId].allTokensIndex = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = tokenInfo[tokenId].ownedTokensIndex;

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            tokenInfo[lastTokenId].ownedTokensIndex = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        tokenInfo[tokenId].ownedTokensIndex = 0;
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = tokenInfo[tokenId].allTokensIndex;

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        tokenInfo[lastTokenId].allTokensIndex = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        tokenInfo[tokenId].allTokensIndex = 0;
        _allTokens.pop();
    }
    
    /**
     * @dev Private function that tells utility token contract to account for an operation
     * @param info uint256 The operation ID (first 8 bits), seriesId is last 8 bits
     * @param param1 uint256 Some more information, if any
     * @param param2 uint256 Some more information, if any
     */
    function _accountForOperation(uint256 info, uint256 param1, uint256 param2) private {
        if (costManager != address(0)) {
            try ICostManager(costManager).accountForOperation(
                _msgSender(), info, param1, param2
            )
            returns (uint256 /*spent*/, uint256 /*remaining*/) {
                // if error is not thrown, we are fine
            } catch Error(string memory reason) {
                // This is executed in case revert() was called with a reason
                revert(reason);
            } catch {
                revert("Insufficient Utility Token: Contact Owner");
            }
        }
    }

    

}
