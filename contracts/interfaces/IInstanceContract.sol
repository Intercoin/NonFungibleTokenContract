// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IInstanceContract {
    function initialize(
        string memory name_, 
        string memory symbol_, 
        string memory contractURI_, 
        string memory baseURI_, 
        string memory suffixURI_, 
        address costManager_, 
        address msgCaller_
    ) external;
    // function name() view external returns(string memory);
    // function symbol() view external returns(string memory);
    // function owner() view external returns(address);
}