//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Lottery is VRFConsumerBaseV2 {
    address payable[] public players;
    address public manager;
    address payable winner;
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

    uint256 internal s_randomWords;
    uint256 internal s_requestId;

    event chooseWinnerBet();

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        manager = msg.sender;
        s_subscriptionId = subscriptionId;
        locked = false;
    }

    receive() external payable isNotLocked {
        require(msg.value == 0.001 ether);
        players.push(payable(msg.sender));
    }

    function getBalance() public view onlyWinnerAndOwner returns (uint256) {
        return address(this).balance;
    }

    function sendBalance() public payable onlyOwner {
        payable(manager).transfer(getBalance());
    }

    function chooseWinner() public onlyOwner isLocked returns (address) {
        require(
            winner == address(0),
            "winner has been choosen, please re start the bet"
        );
        emit chooseWinnerBet();

        winner = players[s_randomWords];
        winner.transfer(getBalance());
        return winner;
    }

    function startNewBid() public onlyOwner isLocked {
        // re set variables
        winner = payable(address(0));
        players = new address payable[](0);
        locked = false;
        s_requestId = 0;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner isNotLocked {
        require(s_requestId == 0, "already request randomWords");
        locked = true;
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
    ) internal override onlyOwner isLocked {
        s_randomWords = (randomWords[0] % players.length) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == manager);
        _;
    }

    modifier onlyWinnerAndOwner() {
        require(msg.sender == manager || msg.sender == winner);
        _;
    }

    modifier isNotLocked() {
        require(locked == false, "Bet is locked");
        _;
    }

    modifier isLocked() {
        require(locked == true, "Bet is Unlocked");
        _;
    }
}
