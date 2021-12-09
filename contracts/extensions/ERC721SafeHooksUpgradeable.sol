// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/ERC721Pausable.sol)

pragma solidity ^0.8.0;

import "../ERC721UpgradeableExt.sol";
import "../interfaces/ISafeHook.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

/**
* hold count of series hooks while token mint
* if in further we would to remove hooks from the list, keep in mind that EnumerableSet does not keep order of items after removing
*/
abstract contract ERC721SafeHooksUpgradeable is Initializable, ERC721UpgradeableExt {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    // hooks 
    //      SERIESID => address SET
    mapping(uint256 => EnumerableSetUpgradeable.AddressSet) hooks;

    // stored hookscount
    //      tokenId     count
    mapping (uint256  => uint256) public hooksCountByToken;

    /**
    * link safeHook contract to certain Series
    * reverted if contract does not ISAfeHook interface
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

        
    }

    /**
    * getting count of hooks for series with `seriesId`
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

    function __ERC721SafeHook_init(string memory name_, string memory symbol_) internal initializer {
        //__Context_init_unchained();
        // __ERC165_init_unchained();
        // __Ownable_init();
        __ERC721_init_unchained(name_, symbol_);
        __ERC721SafeHook_init_unchained();
    }

    function __ERC721SafeHook_init_unchained() internal initializer {
    }
    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) 
        internal 
        virtual 
        override 
    {
        uint256 seriesId = tokenId >> SERIES_BITS;
        for (uint256 i = 0; i < hooksCountByToken[tokenId]; i++) {
            //ISafeHooks(hooks[seriesId].at(i)).transferHook(from, to, tokenId);
            try ISafeHook(hooks[seriesId].at(i)).transferHook(from, to, tokenId) returns (bool success) {
                if (!success) {
                    revert("Transfer Not Authorized");
                }
            } catch {
                revert("Transfer Not Authorized");
            }
        }

        super._beforeTokenTransfer(from, to, tokenId);

        //require(!paused(), "ERC721Pausable: token transfer while paused");
    }
    /**
    * overrode _mint.
    * here we will remember count of series hooks in this moment. so further hooks will not apply for this token
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

        hooksCountByToken[tokenId] = hooks[tokenId >> SERIES_BITS].length();
    }

    uint256[50] private __gap;
}
