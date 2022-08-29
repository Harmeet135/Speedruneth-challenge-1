// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;
  uint256 public deadline = block.timestamp + 72 hours;

  event Stake(address indexed sender, uint256 amount);
 event Withdraw(address indexed sender, uint256 amount);

  uint256 public constant threshold = 1 ether;

      modifier deadlineReached(){
        uint timeRemaining = timeLeft();
        require(timeRemaining == 0, "DeadLine is not reached yet");
        _;
    }
    modifier deadlineRemaining() {
        uint timeRemaining = timeLeft();
        require(timeRemaining > 0, "DeadLine is reached already");
        _;
    }


  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }


  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable stake() function and track individual balances with a mapping:
  //  ( make sure to add a Stake(address,uint256) event and emit it for the frontend <List/> display )
  function stake() public payable deadlineRemaining notCompleted {
 
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }


  // After some deadline allow anyone to call an execute() function
  //  It should either call exampleExternalContract.complete{value: address(this).balance}() to send all the value

  function execute() public notCompleted deadlineReached {
    // uint256 contractBalance = address(this).balance;

  if (address(this).balance > threshold) {
      //  require(address(this).balance >= threshold, "Threshold not reached");

  
    exampleExternalContract.complete{value: address(this).balance}();
  }
  }

  // if the threshold was not met, allow everyone to call a withdraw() function
  // Add a withdraw() function to let users withdraw their balance

  function withdraw() public deadlineReached notCompleted {
    uint256 userBalance = balances[msg.sender];

    require(userBalance > 0, "You don't have balance to withdraw");

    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value: userBalance}("");
    require(sent, "Failed to send user balance back to the user");
  }

  // Add a timeLeft() view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }
  
  // Add the receive() special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}

