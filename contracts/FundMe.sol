// Todo:
// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8; 

import "./PriceConverter.sol";


// When no constant : 872518 gas
// When constant : 850059 gas


/********** Custom Errors **********/
error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    /********** Constant **********/
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    // MINIMUM_USD view function gas:
    // No constant : 23515 gas
    // when constant : 21415 gas

    /********** Arrays & Structs II **********/
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    /********** Immutable **********/
    address public immutable i_owner;
    // No immutable : 23644 gas
    // when immutable : 21508 gas


    /********** Constructor **********/
    constructor() {
        i_owner = msg.sender;
    }


    // Functions and addresses declared payable can receive ether into the contract.
    function fund() public payable{
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract?

        // require(msg.value > 1e18, "Didn't send enough!"); // 1e18 = 1 * 10 ** 18
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); // 1e18 = 1 * 10 ** 18
        // msg.value in 18 decimals


        /**
         * msg.sender (address) : sender of the message 
         * msg.value (uint): number of wei sent with the message
         */
        funders.push(msg.sender); 
        addressToAmountFunded[msg.sender] = msg.value; 

        // What is reverting?
        // undo any action before, and send remaining gas back
    }

    function withDraw() public onlyOwner{
        /********** For Loop **********/
        for(uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funderAddress = funders[funderIndex];
            addressToAmountFunded[funderAddress] = 0;
        }

        /********** Resetting an Array **********/
        funders = new address[](0);

        /********** Sending ETH from a Contract **********/
        // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call  => Recommanded way to send ether
        // (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        // require(callSuccess,  "Call failed");
    }

    /********** Function Modifier **********/
    modifier onlyOwner() {
        // require( msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    /********** Receive & Fallback **********/

    // What happens if someone sends this contract ETH without calling the fund function

    // Special Funation
    // 1. Receive()
    // 2. Fallback()

    /**
     *  Explainer from: https://solidity-by-example.org/fallback/
     *  Ether is sent to contract
     *       is (msg.data) empty?
     *            /   \ 
     *           yes  no
     *           /     \
     *      receive()?  fallback() 
     *       /   \ 
     *     yes   no
     *    /        \
     *  receive()  fallback()
     */  

    receive() external payable {
        fund();
    } 

    fallback() external payable {
        fund();
    }
     


}
