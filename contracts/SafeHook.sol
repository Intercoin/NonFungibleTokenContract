// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ISafeHook.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";

abstract contract SafeHook is ERC165Upgradeable, ISafeHook {
     /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        // return
        //     interfaceId == type(ISafeHook).interfaceId ||
        //     super.supportsInterface(interfaceId);
        return interfaceId == type(ISafeHook).interfaceId;
    }

    // function transferHook(address from, address to, uint256 tokenId) external override returns(bool success) {
    //     revert("need to overrode");
    // }

}
