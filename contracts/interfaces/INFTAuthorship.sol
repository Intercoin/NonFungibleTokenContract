
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTAuthorship {
    
    event TransferAuthorship(address indexed from, address indexed to, uint256 indexed tokenId);
   
    /**
     * can see all the tokens that an author has.
     * @param author author's address
     */
    function tokensByAuthor(address author) external returns(uint256[] memory);
    

    /**
     * @param to address
     * @param tokenId token ID
     */
    function transferAuthorship(address to, uint256 tokenId) external;
    
    /**
     * @param tokenId token ID
     */
    function authorOf(uint256 tokenId) external returns (address);

}
