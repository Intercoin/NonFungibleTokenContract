// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    function canSetUtilityToken(address operator) external view returns (bool);
}
