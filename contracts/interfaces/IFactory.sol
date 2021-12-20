// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    function canOverrideCostManager(address operator, address instance) external view returns (bool);
}
