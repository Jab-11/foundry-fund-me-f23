// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    
    FundMe fundme;
    address USER = makeAddr("Jabarson");
    uint256 constant SEND_VALUE = 0.1 ether; //10e17
    uint256 constant STARTING_BAL = 10 ether;

    function setUp() external{
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER,STARTING_BAL);
        //cheatcode deal - to set some fake money for specified user 
    }

    function testAmtOfUSD() public{
        assertEq(fundme.MINIMUM_USD(),10e18);
    }

    function testOwner()  public {
        // console.log(fundme.i_owner());
        // console.log(msg.sender);
        // assertEq(fundme.i_owner(),address(this));
        assertEq(fundme.getOwner(),msg.sender);
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


    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert();
        fundme.fund();
    }
    modifier funded(){
        vm.prank(USER);
        // prank - cheatcode to make msg.sender a specified address
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded{
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunds() public funded{
        address funder = fundme.getFunder(0);
        assertEq(funder,USER);
    }

    
    function tetOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    } 


    function testWithDrawWithASingleFunder() public funded{
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithDrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        
        assertEq(address(fundme).balance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance, fundme.getOwner().balance);
    }
}