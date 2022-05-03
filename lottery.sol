//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// contract Lottery {
//     address payable[] public players;
//     address public manager;
//     bool private locked;

//     // map rollers to requestIds
//     mapping(uint256 => address) private s_rollers;
//     // map vrf results to rollers
//     mapping(address => uint256) private s_results;

//     VRFCoordinatorV2Interface COORDINATOR;

//     constructor()  {
//         manager = msg.sender;
//         locked = false;
//     }

//     //to receive sent ETH value
//     receive() external payable {
//         require(msg.value == 0.1 ether);
//         players.push(payable(msg.sender));
//     }

//     function getBalance() public view returns(uint){
//         require(manager == msg.sender);
//         return address(this).balance;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == manager);
//         _;
//     }

//     modifier isLocked(){
//         require(locked == false, "Bet is locked");
//         _;
//     }
// }

contract Lottery is VRFConsumerBaseV2 {
    address payable[] public players;
    address public manager;
    address public winner;
    bool private locked;
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;

    event pickRandomNumber();

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        manager = msg.sender;
        s_subscriptionId = subscriptionId;
        locked = false;
    }

    receive() external payable {
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(manager == msg.sender);
        return address(this).balance;
    }

    // function chooseWinner() public onlyOwner returns(address){
    //     locked = true;
    //     emit pickRandomNumber();
    // }


    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords[s_requestId] = (randomWords[0] % players.length) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == manager);
        _;
    }

    modifier isLocked() {
        require(locked == false, "Bet is locked");
        _;
    }
}
