// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./NFTStruct.sol";

abstract contract NFTBase is NFTStruct, ReentrancyGuardUpgradeable, OwnableUpgradeable, ERC721URIStorageUpgradeable, ERC721EnumerableUpgradeable {

    using CountersUpgradeable for CountersUpgradeable.Counter;
    
    CountersUpgradeable.Counter private _tokenIds;
    
    event NewTokenAppear(address author, uint256 tokenId);
    
    modifier onlyIfTokenExists(uint256 tokenId) {
        require(_exists(tokenId), "NFTBase: Nonexistent token");
        _;
    }
    
    modifier onlyNFTOwner(uint256 tokenId) {
        require(_msgSender() == ownerOf(tokenId), "NFTBase: Sender is not owner of token");
        _;
    }
    
    function __NFTBase_init(
        string memory name,
        string memory symbol
    ) 
        internal 
        initializer 
    {
        
        __Ownable_init();
        __ERC721URIStorage_init();
        __ERC721_init(name, symbol);
    }
    
     /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721EnumerableUpgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * creation NFT token
     */
    function _create(
        string memory URI
    ) 
        internal 
        returns(uint256 tokenId)
    {

        tokenId = _tokenIds.current();
        
        emit NewTokenAppear(_msgSender(), tokenId);
        
        // We cannot just use balanceOf or totalSupply to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _safeMint(msg.sender, tokenId);  
        
        _setTokenURI(tokenId, URI);
        
    }
    
    /**
     * must be called after mint to increase 
     */
    function _createAfter(
    ) 
        internal 
    {
        _tokenIds.increment();
    }
    
     
    function _transfer(
        address from, 
        address to, 
        uint256 tokenId
    ) 
        internal 
        override 
    {
        _transferHook(tokenId);
        
        // then usual transfer as expected
        super._transfer(from, to, tokenId);
        
    }
    
    /* solhint-disable */
    function _transferHook(
        uint256 tokenId
    ) 
        internal 
        virtual
    {
        revert("NFTBase: need to be override in child");
    }
    
    /* solhint-enable */

    function tokenURI(uint256 tokenId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function _burn(uint256 tokenId) internal virtual override(ERC721URIStorageUpgradeable, ERC721Upgradeable) {
        super._burn(tokenId);
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
}