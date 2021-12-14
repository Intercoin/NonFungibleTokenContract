// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

abstract contract ERC721UpgradeableExt is ERC165Upgradeable, IERC721MetadataUpgradeable, IERC721EnumerableUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // suffix
    string private _suffixURIs;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 internal constant SERIES_BITS = 192;
    uint256 internal constant DEFAULT_SERIES_ID = 0;
    
    mapping (uint256 => SaleInfo) public salesInfo;  // tokenId => saleInfo
    mapping (uint256 => SeriesInfo) public seriesInfo;  // seriesId => seriesInfo

    mapping(uint256 => uint256) public mintedCountBySeries;
    
    struct SaleInfo { 
        address currency;
        uint256 price;
        uint256 onSaleUntil; 
    }

    struct SeriesInfo { 
        address payable author;
        SaleInfo saleInfo;
        uint256 limit;
        string baseURI; 
        
    }

    event SeriesPutOnSale(
        uint256 indexed seriesId, 
        uint256 price, 
        address currency, 
        uint256 onSaleUntil
    );

    event SeriesRemovedFromSale(
        uint256 indexed seriesId
    );

    event TokenPutOnSale(
        uint256 indexed tokenId, 
        address indexed seller, 
        uint256 price, 
        address currency, 
        uint256 onSaleUntil
    );
    
    event TokenBought(
        uint256 indexed tokenId, 
        address indexed seller, 
        address indexed buyer, 
        address currency, 
        uint256 price
    );

    modifier onlyTokenOwner(uint256 tokenId) {
        require(_ownerOf(tokenId) == _msgSender(), "can call only by owner");
        _;
    }

    modifier onlyOwnerOrAuthor(uint256 seriesId) {
        require(
            seriesInfo[seriesId].author == _msgSender() || 
            owner() == _msgSender(), 
            "!onlyOwnerOrAuthor"
        );
        _;
    }

    /**
    * @dev buys NFT for ETH with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param safe use safeMint and safeTransfer or not
    */

    function buy(uint256 tokenId, bool safe) public payable nonReentrant {
        (bool success, bool exists, SaleInfo memory data, address owner) = _isOnSale(tokenId);
        require(success, "token is not on sale");
        require(msg.value >= data.price, "insufficient ETH");
        require(address(0) == data.currency, "wrong currency for sale");

        bool transferSuccess;
        (transferSuccess, ) = owner.call{gas: 3000, value: data.price}(new bytes(0));
        require(transferSuccess, "TRANSFER_TO_OWNER_FAILED");

        uint256 refund = msg.value - data.price;
        if (refund > 0) {
            (transferSuccess, ) = msg.sender.call{gas: 3000, value: refund}(new bytes(0));
            require(transferSuccess, "REFUND_FAILED");
        }

        _buy(tokenId, exists, data, owner, safe);
    }

    /**
    * @dev buys NFT for specified currency with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param currency address of token to pay with
    * @param price amount of specified token to pay
    * @param safe use safeMint and safeTransfer or not
    */
    function buy(uint256 tokenId, address currency, uint256 price, bool safe) public nonReentrant {
        (bool success, bool exists, SaleInfo memory data, address owner) = _isOnSale(tokenId);
        require(success, "token is not on sale");
        require(currency == data.currency, "wrong currency for sale");
        uint256 allowance = IERC20Upgradeable(data.currency).allowance(_msgSender(), address(this));
        require(allowance >= data.price && price >= data.price, "insufficient amount");
        IERC20Upgradeable(data.currency).transferFrom(_msgSender(), owner, data.price);

        _buy(tokenId, exists, data, owner, safe);
    }

    /**
    * @dev sets information for series with 'seriesId'. 
    * @param seriesId series ID
    * @param info new info to set
    */
    function setSeriesInfo(
        uint256 seriesId, 
        SeriesInfo memory info 
    ) 
        onlyOwnerOrAuthor(seriesId)
        external
    {
        
        if (info.saleInfo.onSaleUntil > seriesInfo[seriesId].saleInfo.onSaleUntil) {
            emit SeriesPutOnSale(seriesId, info.saleInfo.price, info.saleInfo.currency, info.saleInfo.onSaleUntil);
        } else if (info.saleInfo.onSaleUntil == 0 ) {
            emit SeriesRemovedFromSale(seriesId);
        }
        
        seriesInfo[seriesId] = info;

    }

    /**
    * @dev gives the info for sale of NFT with 'tokenId'. 
    * @param tokenId token ID
    */
    function getSaleInfo(uint256 tokenId) external view returns(SaleInfo memory) {
        return salesInfo[tokenId];
    }

    /**
    * @dev gives the info for series with 'seriesId'. 
    * @param seriesId series ID
    */
    function getSeriesInfo(uint256 seriesId) external view returns(SeriesInfo memory) {
        return seriesInfo[seriesId];
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
        uint256 duration
    )
        external 
    {
        (bool success, /*bool isExists*/, SaleInfo memory data, address owner) = _isOnSale(tokenId);
        require(!success, "already in sale");
        require(owner == _msgSender(), "invalid token owner");
        require(duration > 0, "invalid duration");

        data.onSaleUntil = block.timestamp + duration;
        data.price = price;
        data.currency = currency;
        setSaleInfo(tokenId, data);

        emit TokenPutOnSale(tokenId, _msgSender(), data.price, data.currency, data.onSaleUntil);
    }

    /**
    * @dev gives the list of all NFTs owned by 'account'
    * @param account address of account
    */
    function tokensByOwner(
        address account
    ) 
        external
        view
        returns (uint256[] memory ret)
    {
        return _tokensByOwner(account, 0);
    }

    /**
    * @dev gives the list of all NFTs owned by 'account' with limit
    * @param account address of account
    */
    function tokensByOwner(
        address account,
        uint256 limit
    ) 
        external
        view
        returns (uint256[] memory ret)
    {
        return _tokensByOwner(account, limit);
    }

    /**
    * @dev mints and distributed NFTs with specified IDs
    * to specified addresses
    * @param tokenIds list of NFT IDs t obe minted
    * @param addrs list of receiver addresses
    */
    function mintAndDistribute(uint256[] memory tokenIds, address[] memory addrs) external onlyOwner {
        uint256 len = addrs.length;
        require(tokenIds.length == len, "lengths should be the same");
        for(uint256 i = 0; i < len; i++) {
            //require(seriesInfo[tokenIds[i] >> SERIES_BITS].sequential == false, "tokenId should be in none-sequential series")
            _mint(addrs[i], tokenIds[i]);
        }
    }

    /**
    * @dev sets sale info for the NFT with 'tokenId'
    * @param tokenId token ID
    * @param info information about sale 
    */
    function setSaleInfo(
        uint256 tokenId, 
        SaleInfo memory info 
    ) 
        public onlyTokenOwner(tokenId)
    {
        salesInfo[tokenId] = info;
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
        _name = newName;
        _symbol = newSymbol;
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        string memory _tokenURI = tokenId.toString();
        string memory base = seriesInfo[tokenId >> SERIES_BITS].baseURI;
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return  string(abi.encodePacked(_tokenURI));
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI, _suffixURIs));
        }
        return "";

        // return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
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

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

        return _tokenApprovals[tokenId];
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
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
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    function _buy(uint256 tokenId, bool exists, SaleInfo memory data, address owner, bool safe) internal virtual {
        if (exists) {
            if (safe) {
                _safeTransfer(owner, _msgSender(), tokenId, new bytes(0));
            } else {
                _transfer(owner, _msgSender(), tokenId);
            }
            salesInfo[tokenId].onSaleUntil = 0;
            emit TokenBought(tokenId, owner, _msgSender(), data.currency, data.price);

        } else {
            if (safe) {
                _safeMint(_msgSender(), tokenId);
            } else {
                _mint(_msgSender(), tokenId);
            }
            emit Transfer(owner, _msgSender(), tokenId);
            emit TokenBought(tokenId, seriesInfo[tokenId >> SERIES_BITS].author, _msgSender(), data.currency, data.price);
        }

    }

    /**
    * @dev returns if token is on sale or not, does it exist or not, data about sale and it's owner
    * @param tokenId token ID 
    */
    
    function _isOnSale(uint256 tokenId) 
        internal 
        view 
        returns
        (
            bool success,
            bool exists, 
            SaleInfo memory data,
            address owner
        ) 
    {
        //success = false;
        data = salesInfo[tokenId];
        exists = _exists(tokenId);
        owner = _owners[tokenId];

        if (owner != DEAD_ADDRESS) {
            if (owner != address(0)) { 
                if (data.onSaleUntil > block.timestamp) {
                    success = true;
                } 
            } else {   
                uint256 seriesId = tokenId >> SERIES_BITS;
                SeriesInfo memory seriesData = seriesInfo[seriesId];
                if (seriesData.saleInfo.onSaleUntil > block.timestamp) {
                    success = true;
                    data = seriesData.saleInfo;
                    owner = seriesData.author;
                }
            }
        } 
    }
      
    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init();
        __ERC165_init();
        __Ownable_init();
        __ReentrancyGuard_init();

        
        _name = name_;
        _symbol = symbol_;
        _suffixURIs = ".json";

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
        return _owners[tokenId] != address(0);
    }

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
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
        address owner = ownerOf(tokenId);
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
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        uint256 seriesId = tokenId >> SERIES_BITS;
        mintedCountBySeries[seriesId] += 1;

        if (seriesInfo[seriesId].limit != 0) {
            require(mintedCountBySeries[seriesId] <= seriesInfo[seriesId].limit, "exceed series limit");
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
        
        //delete _owners[tokenId];
        _balances[DEAD_ADDRESS] += 1;
        _owners[tokenId] = DEAD_ADDRESS;
        ///----
        
        //emit Transfer(owner, address(0), tokenId);
        emit Transfer(owner, DEAD_ADDRESS, tokenId);

        // if (bytes(_tokenURIs[tokenId]).length != 0) {
        //     delete _tokenURIs[tokenId];
        // }
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
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        // and change implementation of _transfer() to simply replace tokenInfo[tokenId].owner without calling setSaleInfo. 

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
    
    /**
    * @param account account
    * @param limit limit
    */
    function _tokensByOwner(
        address account,
        uint256 limit
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


    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
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
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

}
