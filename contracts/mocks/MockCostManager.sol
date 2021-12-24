// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/ICostManager.sol";
import "../lib/StringsW0x.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "hardhat/console.sol";

contract MockCostManager is ICostManager, ERC165Upgradeable {
    using StringsW0x for uint256;

    uint8 public lastOperationId;
    uint64 public lastSeriesId;
    function accountForOperation(address sender, uint256 info, uint256 param1, uint256 param2) external override returns(uint256 spent, uint256 remaining){
        lastOperationId = uint8(info >> 64);
        lastSeriesId = uint64(info % 2**64);

    }

}