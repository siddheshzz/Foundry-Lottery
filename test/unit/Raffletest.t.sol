// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";

import {Test, console} from "forge-std/Test.sol";

contract RaffleTest is Test{


    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig = new HelperConfig();

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;


    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external{
        DeployRaffle deployer = new DeployRaffle();
        (raffle,helperConfig) = deployer.run();
        vm.deal(PLAYER,  STARTING_USER_BALANCE);

        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link
        ) = helperConfig.activeNetworkConfig();

        vm.stopPrank();
    }

    function testInitializeInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN );
    }

    //Enter Raffle
    /**
    testRaffleRevertsWHenYouDontPayEnought
    testRaffleRecordsPlayerWhenTheyEnter
    testEmitsEventOnEntrance
    testDontAllowPlayersToEnterWhileRaffleIsCalculating
    
    
     */


    function testRaffleRevertsWhenYouDontPayEnough() public{
        //Arrange
        vm.prank(PLAYER);
        //Act / Assert

        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);

        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public{

        vm.prank(PLAYER);

        raffle.enterRaffle{value:entranceFee}();
        // assert

        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }
    function testEmitsEventOnEntrance() public{
        vm.prank(PLAYER);

        vm.expectEmit(true, false, false,false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value:entranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public{
        vm.prank(PLAYER);

        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp+interval+1);
        vm.roll(block.number+1);
        raffle.performUpKeep();

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);

        raffle.enterRaffle{value:entranceFee}();

    }

}