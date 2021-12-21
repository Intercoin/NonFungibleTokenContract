// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721UpgradeableExt.sol";
import "../interfaces/ISafeHook.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

/**
* holds count of series hooks while token mint and buy
*/
abstract contract ERC721SafeHooksUpgradeable is Initializable, ERC721UpgradeableExt {
    
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping (uint256 => uint256) public hooksCountByToken; // token ID => hooks count

    mapping(uint256 => EnumerableSetUpgradeable.AddressSet) internal hooks;    // series ID => hooks' addresses

    event NewHook(uint256 seriesId, address contractAddress);

    /**
    * @dev buys NFT for ETH with defined id. 
    * mint token if it doesn't exist and transfer token
    * if it exists and is on sale
    * @param tokenId token ID to buy
    * @param price amount of specified ETH to pay
    * @param safe use safeMint and safeTransfer or not
    * @param hookCount number of hooks 
    */
    function buy(
        uint256 tokenId, 
        uint256 price, 
        bool safe, 
        uint256 hookCount
    ) 
        external
        payable
    {
        validateHookCount(tokenId, hookCount);    
        super.buy(tokenId, price, safe);
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
        external
    {
        validateHookCount(tokenId, hookCount);    
        super.buy(tokenId, currency, price, safe);
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
    * @param tokenId token ID
    * @param hookCount hook count
    */
    function validateHookCount(
        uint256 tokenId,
        uint256 hookCount
    ) 
        internal 
        view 
    {
        uint256 seriesId = tokenId >> SERIES_SHIFT_BITS;
        require(hookCount == hooksCount(seriesId), "wrong hookCount");
    }

    /**
    * @param name_ name 
    * @param symbol_ symbol 
    */
    function __ERC721SafeHook_init(
        string memory name_, 
        string memory symbol_, 
        address costManager_,
        address msgSender_
    ) 
        internal 
        initializer 
    {
        __ERC721_init(name_, symbol_, costManager_, msgSender_);
    }

    /**
     * @dev Overriden function _beforeTokenTransfer with
     * hooks executing 
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
        uint256 seriesId = tokenId >> SERIES_SHIFT_BITS;
        for (uint256 i = 0; i < hooksCountByToken[tokenId]; i++) {
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

        super._beforeTokenTransfer(from, to, tokenId);

    }
    /**
    * @dev overriden _mint function.
    * Here we remember count of series hooks at this moment. 
    * So further hooks will not apply for this token
    */
    function _mint(
        address to, 
        uint256 tokenId
    ) 
        internal 
        virtual 
        override
    {
        _storeHookCount(tokenId);
        super._mint(to, tokenId);
    }

    /**
    * @dev overriden _buy function.
    * Here we remember count of series hooks at this moment. 
    * So further hooks will not apply for this token
    */
    function _buy(
        uint256 tokenId, 
        bool exists, 
        SaleInfo memory data, 
        address owner, 
        bool safe
    ) 
        internal 
        override 
    {
        _storeHookCount(tokenId);
        super._buy(tokenId, exists, data, owner, safe);
        
    }

    /** 
    * @dev used to storage hooksCountByToken at this moment
    */
    function _storeHookCount(
        uint256 tokenId
    )
        internal
    {
        hooksCountByToken[tokenId] = hooks[tokenId >> SERIES_SHIFT_BITS].length();
    }
}
