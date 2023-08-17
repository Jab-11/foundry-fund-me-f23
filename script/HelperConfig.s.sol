// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeConfig;

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
            activeConfig = getAnvilEthConfig();
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
    function getAnvilEthConfig() public returns(NetworkConfig memory){
        vm.startBroadcast();
        MockV3Aggregator mockpricefeed = new MockV3Aggregator(8,2000e8);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockpricefeed)});
        return anvilConfig;
    }
}