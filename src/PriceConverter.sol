// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//Libraries in solidity are similar to contracts that contain reusable codes.
//The library does not have state variables, it cannot inherit any element and cannot be inherited.

library PriceConverter{
    //function to getprice of ETH in USD
    function getPrice() internal  view returns(uint256){
        //ABI
        //Address - 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // https://docs.chain.link/data-feeds/price-feeds/addresses#Sepolia%20Testnet
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 answer,,,) = priceFeed.latestRoundData();
        //ETH in USD
        return uint256(answer*1e10);
    }

    //function to get version of contract
    function getVersion() internal view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return  priceFeed.version();
    }

    // function to get conversionrate
    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint ethprice = getPrice();
        //returns 3000_000,000,000,000,000,000
        //for 1_000,000,000,000,000,000 eth

        uint256 ethAmountInUsd = (ethAmount * ethprice) / 1e18;

        // 1eth = 3000usd
        // 2eth = ?
        // ? = 2 * 3000 / 1
        return ethAmountInUsd;
    }
}