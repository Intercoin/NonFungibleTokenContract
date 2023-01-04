// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ICommunity {
    function isMemberHasRole(address account, string memory rolename) external returns(bool);
}