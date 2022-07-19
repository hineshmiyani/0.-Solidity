// SPDX-License-Identifier: MIT

pragma solidity  ^0.8.0;

import "./SimpleStorage.sol";




// Solidity supports multiple inheritance. Contracts can inherit other contract by using the is keyword.
contract ExtraStorage is SimpleStorage {
    /********** 7: Inheritence: **********/
    // virtual & override :
    // Function that is going to be overridden by a child contract must be declared as virtual.
    // Function that is going to override a parent function must use the keyword override.
    
    function store(uint256  _favoriteNumber) public override {
        favoriteNumber = _favoriteNumber + 5;
    }
}