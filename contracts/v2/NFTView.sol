// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma abicoder v2;

import "./NFTStorage.sol";

contract NFTView is NFTStorage {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    // using AddressUpgradeable for address;
    using StringsW0x for uint256;
    
    /********************************************************************
    ****** external section *********************************************
    *********************************************************************/

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
    ****** public section *********************************************
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
        require(index < _balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
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
    function supportsInterface(bytes4 interfaceId) public view virtual override /*override(ERC165Upgradeable, IERC165Upgradeable)*/ returns (bool) {
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
        // require(owner != address(0), "ERC721: balance query for the zero address");
        // return _balances[owner];
        return _balanceOf(owner);
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = __ownerOf(tokenId);
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        return _getApproved(tokenId);
    }

    
    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _isApprovedForAll(owner, operator);
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
        return _getTokenSaleInfo(tokenId);
    }

    /********************************************************************
    ****** internal section *********************************************
    *********************************************************************/

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
        uint256 len = _balanceOf(account);
        if (len > 0) {
            len = (limit != 0 && limit < len) ? limit : len;
            array = new uint256[](len);
            for (uint256 i = 0; i < len; i++) {
                array[i] = _ownedTokens[account][i];
            }
        }
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

    function _canManageSeries(uint64 seriesId) internal view returns(bool) {
        return owner() == _msgSender() || seriesInfo[seriesId].author == _msgSender();
    }
    
    function _canManageToken(uint256 tokenId) internal view returns (bool) {
        return __ownerOf(tokenId) == _msgSender()
            || _getApproved(tokenId) == _msgSender()
            || _isApprovedForAll(__ownerOf(tokenId), _msgSender());
    }
   
}