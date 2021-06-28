// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTBase.sol";

abstract contract NFTAuthorship is NFTBase {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    function __NFTAuthorship_init(
        string memory name,
        string memory symbol
    ) 
        internal 
        initializer 
    {
        __NFTBase_init(name, symbol);
    }

    // Mapping from token ID to author address
    mapping (uint256 => address) private _authors;
    mapping (address => EnumerableSetUpgradeable.UintSet) private _authoredTokens;
    
    
    modifier onlyNFTAuthor(uint256 tokenId) {
        require(_msgSender() == _getAuthor(tokenId), "NFTAuthorship: sender is not author of token");
        _;
    }
    
    event TransferAuthorship(address indexed from, address indexed to, uint256 indexed tokenId);
   
    /**
     * can see all the tokens that an author has.
     * @param author author's address
     */
    function tokensByAuthor(
        address author
    ) 
        public 
        view 
        returns(uint256[] memory) 
    {
        uint256 len = _authoredTokens[author].length();
        uint256[] memory ret = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            ret[i] = _authoredTokens[author].at(i);
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
        onlyIfTokenExists(tokenId)
        onlyNFTAuthor(tokenId)
    {
        address author = _getAuthor(tokenId);
        require(to != author, "NFTAuthorship: transferAuthorship to current author");
        
        _setAuthor(tokenId, author, to);
        
        emit TransferAuthorship(author, to, tokenId);
    }
    
    /**
     * @param tokenId token ID
     */
    function authorOf(
        uint256 tokenId
    )
        public
        onlyIfTokenExists(tokenId)
        view
        returns (address) 
    {
        address author = _getAuthor(tokenId);
        return author;
    }
    
    /**
     * @param to address
     * @param tokenId token ID
     */
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
        override 
    {
        super._mint(to, tokenId);
        
        _setAuthor(tokenId, address(0), _msgSender());
        emit TransferAuthorship(address(0), _msgSender(), tokenId);
        
    }
    
    /**
     * @param tokenId token ID
     */
    function _burn(
        uint256 tokenId
    ) 
        internal 
        virtual 
        override 
    {
        super._burn(tokenId);
        delete _authors[tokenId];

    }
   
    /**
     * @param tokenId token ID
     * @param from old author's address(if address == address(0) - it's newly created NFT)
     * @param to new old author's address(if address == address(0) - old owner renounced ownership)
     */
    function _setAuthor(
        uint256 tokenId, 
        address from, 
        address to
    ) 
        private 
    {
        _authors[tokenId] = to;
        _authoredTokens[from].remove(tokenId); // old author
        _authoredTokens[to].add(tokenId); // new author
        
    }
    
    /**
     * @param tokenId token ID
     */
    function _getAuthor(
        uint256 tokenId
    ) 
        private 
        view 
        returns (address)  
    {
        return _authors[tokenId];
    }
    
}