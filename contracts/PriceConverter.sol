// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * Importing from GitHub & NPM
 */
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


/********** Libraries **********/
library PriceConverter {

     /********** Floating Point Math in Solidity **********/
    // get latest eth price
    function getPrice() internal view returns (uint256) {
        // ABI 
        // Address : 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int price,,,) = priceFeed.latestRoundData();
        
        /**
         * ETH in terms of USD
         * 3000.00000000  // price in 8 decimals
         * so, convert into 18 decimals => multiply by 1e10 👇👇
         */
    
        return uint256(price * 1e10); // 1**10 = 10000000000
    } 

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    // convert eth Amount  in USD 
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();

        // ethPrice => 3000_000000000000000000 = ETH / USD price
        // ethAmount => 1_000000000000000000 ETH

        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18; 
        return ethAmountInUSD; //3000
    }

} 