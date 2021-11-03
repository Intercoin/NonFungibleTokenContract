// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "./NFTBase.sol";
import "./interfaces/INFTAuthorship.sol";

abstract contract NFTAuthorship is NFTBase, INFTAuthorship {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeMathUpgradeable for uint256;
    
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
    
    mapping (uint256 => address[]) private authorsHistory;
    
    EnumerableSetUpgradeable.AddressSet totalAuthorsList;
    
    // modifier onlyNFTAuthor(uint256 tokenId) {
    //     require(_msgSender() == _getAuthor(tokenId), "NFTAuthorship: sender is not author of token");
    //     _;
    // }
    
    function _validateTokenAuthor(uint256 tokenId) internal view {
        require(_msgSender() == _getAuthor(tokenId), "Sender is not author of token");
    }
    
    /**
     * can see all the tokens that an author has.
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
        override
        // onlyIfTokenExists(tokenId)
        // onlyNFTAuthor(tokenId)
    {
        _validateOnlyIfTokenExists(tokenId);
        _validateTokenAuthor(tokenId);
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
        override
        //onlyIfTokenExists(tokenId)
        view
        returns (address) 
    {
        _validateOnlyIfTokenExists(tokenId);
        address author = _getAuthor(tokenId);
        return author;
    }
    
    function historyOfAuthors(
        uint256 tokenId
    )
        public 
        view
        returns(address[] memory) 
    {
        uint256 len = authorsHistory[tokenId].length;
        address[] memory ret = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            ret[i] =  authorsHistory[tokenId][i];
        }
        return ret;
    }
    
    function getAllAuthors(
    ) 
        public
        view 
        returns(address[] memory) 
    {
        uint256 len = totalAuthorsList.length();
        
        address[] memory ret = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            ret[i] = totalAuthorsList.at(i);
            
        }
        
        return ret;
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
     */
    function _getAuthor(
        uint256 tokenId
    ) 
        internal 
        view 
        returns (address)  
    {
        return _authors[tokenId];
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
        authorsHistory[tokenId].push(to);
        
        _authors[tokenId] = to;
        _authoredTokens[from].remove(tokenId); // old author
        _authoredTokens[to].add(tokenId); // new author
        
        
        if (to != address(0)) {
            totalAuthorsList.add(to);
        } else {
            if (_authoredTokens[from].length() == 1) {
                totalAuthorsList.remove(from);    
            }    
        }
        
        
        //_coauthors[tokenId].removeIfExists(to);
    }
    
    
    
}