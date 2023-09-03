// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig{
        address priceFeed;
    }
    constructor(){
        if (block.chainid == 11155111){
            activeConfig = getSepoliaEthConfig();
        }
        else if(block.chainid == 1){
            activeConfig = getMainEthConfig();
        }
        else{
            activeConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepConfig;

    }
    function getMainEthConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainConfig;
    }
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        if (activeConfig.priceFeed!=address(0)){
            return activeConfig;
        }
        
        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockpricefeed)});
        return anvilConfig;
    }
}