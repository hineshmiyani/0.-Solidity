// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SimpleStorage.sol";

contract StorageFactory {
    //simpleStorageArray 
    SimpleStorage[] public simpleStorageArray;

    function createSimpleStorageContract() public {
       SimpleStorage simpleStorage = new SimpleStorage();
       simpleStorageArray.push(simpleStorage);
    }


    /********** 6: Interecting with other contracts: **********/
    // Add Store value by Index from simpleStorageArray 
    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public{
        // Address
        // AIB : Application Binary Interface
        simpleStorageArray[_simpleStorageIndex].store(_simpleStorageNumber);
    }


    // Get Store value by Index from simpleStorageArray 
    function sfGet(uint256 _simpleStorageIndex) public view returns(uint256) {
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }

    


}