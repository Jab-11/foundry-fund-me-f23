// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test{
    
    FundMe fundme;

    function setUp() external{
        fundme = new FundMe();
    }

    function testAmtOfUSD() public{
        assertEq(fundme.MINIMUM_USD(),10e18);
    }

    function testOwner()  public {
        // console.log(fundme.i_owner());
        // console.log(msg.sender);
        assertEq(fundme.i_owner(),address(this));
    }

    function testPriceFeedVersion() public{
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }
    // what can be done to work with address outside of system?
    // 1. Unit
    // - Testing a specific part of our code
    // 2. Integration
    // - Testing how our code works with other part of our code
    // 3. Forked
    // - Testing our code on a simulated real environment
    // 4. Staging
    // - Testing our code on a real environment that is not prod 
}