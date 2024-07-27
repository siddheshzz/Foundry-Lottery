// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/// @title Sample Raffle Contract
/// @author Alchemist
/// @notice This contract is for creating a sample raffle
/// @dev Implement chainlink VRF2


contract Raffle is VRFConsumerBaseV2Plus{

    enum RaffleState{
        OPEN,
        CALCULATING
    }
    
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;




    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    //@dev duration of lottery in sec
    uint256 internal immutable i_interval;
    address private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeStamp;
    address private s_recentWinner;

    RaffleState private s_raffleState;

    /** Events */
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(uint256 currentBalance, uint256 numberOfPlayers, uint256 raffleState);



    constructor(

        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    
    )VRFConsumerBaseV2Plus(vrfCoordinator){
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_gasLane = gasLane;
        // i_vrfCoordinator = vrfCoordinator;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }
    

    function enterRaffle() external payable{
        // require(msg.value >= i_entranceFee,"Not Enough ETH sent!");
        if(msg.value< i_entranceFee){
            revert Raffle__NotEnoughEthSent();
        }
        if(s_raffleState!= RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }
    /**
    //When is winner is supposed to be picked
    notice Explain to an end user what this does
    /// dev This is th function that Chainlink automation nodes call
    ///      to see if its time to perform upkeep
    ///      Following should be true for this to return true:-
    ///         1. The time interval has passed between raffle runs(consecative runs))
    ///         2. The raffle is in OPEN state
    ///         3. The contract has ETH aka Players
    ///         4. (Implicite) The function is funded by LINK
    /// param 
    return upkeepNeeded
    /// inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    */
    function checkUpKeep(bytes memory /* Check data  */)public view returns (bool upkeepNeeded, bytes memory /*performData*/){
        bool timeHasPassed = (block.timestamp- s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded,"0x0");
    }


    //get random number
    //use the random number to pick a player
    //be atomatically called - help by chainlink automation
    function performUpKeep() external{
        (bool upKeepNeeded,) = checkUpKeep("");
        if(!upKeepNeeded){
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        //check if enough time is passed
        if((block.timestamp- s_lastTimeStamp) < i_interval){
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;
        s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: true
                    })
                )
            })
        );

    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    )internal override{

        uint256 indexOfWinner = _randomWords[0]%s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit PickedWinner(winner);

        (bool success,) = winner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
    }


    /** Getter Funtions */

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }

    function getRaffleState() external view returns(RaffleState){
        return s_raffleState;
    }

    function getPlayer(uint256 index) external view returns(address){
        return s_players[index];
    }

}