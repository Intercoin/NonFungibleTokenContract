// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
//import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

abstract contract NFTAuthorship is /*ContextUpgradeable, */ERC721URIStorageUpgradeable {

    function __NFTAuthorship_init(
        string memory name,
        string memory symbol
    ) 
        internal 
        initializer 
    {
        __ERC721URIStorage_init();
        __ERC721_init(name, symbol);
    }


    // Mapping from token ID to author address
    mapping (uint256 => address) private _authors;
    
    event TransferAuthorship(address indexed from, address indexed to, uint256 indexed tokenId);
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function transferAuthorship(
        address to, 
        uint256 tokenId
    ) 
        public 
    {
        address author = authorOf(tokenId);
        require (msg.sender == author, "NFTAuthorship: caller is not author");
        require(to != author, "NFTAuthorship: transferAuthorship to current author");
        
        _setAuthor(tokenId, to);
        emit TransferAuthorship(author, to, tokenId);
    }
    
    function authorOf(uint256 tokenId) public view returns (address) {
        address author = _getAuthor(tokenId);
        require(author != address(0), "NFTAuthorship: author query for nonexistent token");
        return author;
    }
    
    function _mint(address to, uint256 tokenId) internal virtual override {
        super._mint(to, tokenId);
        
        _setAuthor(tokenId, msg.sender);
        emit TransferAuthorship(address(0), msg.sender, tokenId);
        
    }
    
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _authors[tokenId];

    }
    
    function _setAuthor(uint256 tokenId, address addr) private {
        _authors[tokenId] = addr;
    }
    function _getAuthor(uint256 tokenId) private view returns (address)  {
        return _authors[tokenId];
    }
}