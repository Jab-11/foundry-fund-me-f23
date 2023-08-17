// SPDX-License-Identifier: MIT
pragma solidity 0.8;

import {PriceConverter} from "../src/PriceConverter.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//original gas - 8,03,045
//use of constant - 7,83,087
error FundMe_NotOwner();

contract FundMe{
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 10 * 1e18;
    //1 ETH = 10^9 Gwei (1Billion) = 10^18 Wei(1000Quadrillion)
    // execution cost
        //constant - 351
        //original - 2451
    //For constant variables, the value has to be a constant at compile time 
    //and it has to be assigned where the variable is declared. 
    address[] public funds;
    mapping(address=>uint256) public AddresstoFund;

    //to make withdraw only accisble by owner(deployer)
    address public immutable i_owner;
    //Variables declared as immutable are a bit less restricted than 
    //those declared as constant: 
    //Immutable variables can be assigned an arbitrary value 
    //in the constructor of the contract or at the point of their declaration. 

    // execution cost
        //immutable - 466
        //original - 2602
    constructor(){
        i_owner = msg.sender;
    }


    function fund() public payable {
        //payaable - makes func to interact with ETH(etc.)
        //it makes button red
        //contract can hold fund due to this
        
        //msg.value is a member of the msg (message) object when sending (state transitioning) transactions on the Ethereum network.
        //msg.value is a special global variable in Solidity that represents the amount of Ether (cryptocurrency) sent along with a function call to a smart contract
        //require - checkes condition
        //e condition specified in require evaluates to false, the contract execution will revert and any changes made prior to the require statement will be rolled back.

        require(msg.value.getConversionRate() >= MINIMUM_USD, "The minimum amount is 10$"); //1e18 = 10^18 wei = 1eth
        funds.push(msg.sender);
        AddresstoFund[msg.sender] += msg.value;
    }

    //modifier to only accesible by owner
    modifier OnlyOwner{
        // require(msg.sender == i_owner,"Only Owner can access this function.");
        // for more gas efficient
        if(msg.sender!=i_owner){revert FundMe_NotOwner();}
        _;
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
    }    
    function withdraw() public OnlyOwner{
        for(uint fundIndex=0; fundIndex < funds.length; fundIndex++){
            address funder = funds[fundIndex];
            AddresstoFund[funder] = 0;
        }
        //reset the array to null
        funds = new address[](0);

        //actually withdraw funds
        
        //How to send Ether?
        //You can send Ether to other contracts by

        // (1)
        // transfer (2300 gas, throws error)
        // payable(msg.sender).transfer(address(this).balance);
        // This function is no longer recommended for sending Ether.

        // (2)
        // send (2300 gas, returns bool)
        // bool SendSuccess = payable(msg.sender).send(address(this).balance);
        // require(SendSuccess,"Send Failed");
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.

        // (3)
        // call (forward all gas or set gas, returns bool)
        (bool CallSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(CallSuccess,"Call Failed");
        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
    }

    //What happens when someone sends this contract ETH without
    //calling the fund function

    //Receive Ether Function
    //A contract can have at most one receive function, 
    //declared using receive() external payable { ... }
    //The receive function is executed on a call to the contract with empty calldata. 
    //This is the function that is executed on plain Ether transfers.

    //Fallback Function
    //A contract can have at most one fallback function, declared using 
    //either fallback () external [payable] or
    //fallback (bytes calldata input) external [payable] returns (bytes memory output).
    // // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return  priceFeed.version();
    }
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}