//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";

contract Lottery is VRFv2Consumer {
    address payable[] public players;
    address public manager;
    bool private locked;


    constructor()
    {
        manager = msg.sender;
        locked = false;
    }

    event RequestRandomness(
        bytes32 indexed requestId,
        bytes32 keyHash,
        uint256 seed
    );
    
    event RequestRandomnessFulfilled(
        bytes32 indexed requestId,
        uint256 randomness
    );

    //to receive sent ETH value
    receive() external payable {
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    } 

    function getBalance() public view returns(uint){
        require(manager == msg.sender);
        return address(this).balance;
    }

    function random() public view onlyOwner isLocked returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length, gasleft())));
    } 

    modifier isLocked(){
        require(locked == false, "Bet is locked");
        _;
    }
}