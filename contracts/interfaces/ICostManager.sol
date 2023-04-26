// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

interface ICostManager is IERC165Upgradeable {
    function accountForOperation(
        address sender,
        uint256 info,
        uint256 param1,
        uint256 param2
    ) external returns (uint256 spent, uint256 remaining);
}
