// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ICostManager {
    function accountForOperation(address sender, uint256 info, uint256 param1, uint256 param2) external returns(uint256 spent, uint256 remaining);
}