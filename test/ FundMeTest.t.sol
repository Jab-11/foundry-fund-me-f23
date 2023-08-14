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
        console.log(fundme.i_owner());
        console.log(msg.sender);
        assertEq(fundme.i_owner(),address(this));
    }

}