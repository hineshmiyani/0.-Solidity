// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract SafeMathTester {
    /**** SafeMath, Overflow Checking, and the "unchecked" keywork ****/
    uint8 public bigInt  = 255;

    function add() public {
        bigInt = bigInt + 1; // checked
        // unchecked {bigInt = bigInt + 1;} // unchecked
    }
}