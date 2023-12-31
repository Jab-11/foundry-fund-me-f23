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
    address[] private s_funds;
    mapping(address=>uint256) private s_AddresstoFund;

    //to make withdraw only accisble by owner(deployer)
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;
    //Variables declared as immutable are a bit less restricted than 
    //those declared as constant: 
    //Immutable variables can be assigned an arbitrary value 
    //in the constructor of the contract or at the point of their declaration. 

    // execution cost
        //immutable - 466
        //original - 2602
    constructor(address priceFeed){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }


    function fund() public payable {
        //payaable - makes func to interact with ETH(etc.)
        //it makes button red
        //contract can hold fund due to this
        
        //msg.value is a member of the msg (message) object when sending (state transitioning) transactions on the Ethereum network.
        //msg.value is a special global variable in Solidity that represents the amount of Ether (cryptocurrency) sent along with a function call to a smart contract
        //require - checkes condition
        //e condition specified in require evaluates to false, the contract execution will revert and any changes made prior to the require statement will be rolled back.

        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "The minimum amount is 10$"); //1e18 = 10^18 wei = 1eth
        s_funds.push(msg.sender);
        s_AddresstoFund[msg.sender] += msg.value;
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

    function cheaperWithdraw() public OnlyOwner{
        uint256 fundsLength = s_funds.length;
        for(uint fundIndex=0; fundIndex < fundsLength; fundIndex++){
            address funder = s_funds[fundIndex];
            s_AddresstoFund[funder] = 0;
        }
        s_funds = new address[](0);
        (bool CallSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(CallSuccess,"Call Failed");
    }

    function withdraw() public OnlyOwner{
        for(uint fundIndex=0; fundIndex < s_funds.length; fundIndex++){
            address funder = s_funds[fundIndex];
            s_AddresstoFund[funder] = 0;
        }
        //reset the array to null
        s_funds = new address[](0);

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

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }


    // Getters
    function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
        return s_AddresstoFund[fundingAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funds[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}