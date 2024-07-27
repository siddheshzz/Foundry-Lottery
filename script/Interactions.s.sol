
pragma solidity ^0.8.18;

import {Scrip,console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

import {VRFCoordinatorV2Mock} from "@chainlink/contract/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscriptions is Script{
    function createSubscriptionUsingConfig() public returns(uint64){
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinator,
            ,
            ,
            
        ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns(uint264){
        console.log("Creating Subscription on chainId: ",block.chainId);

        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is : ", subId);
        console.log("Please update subscriptionId in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns(uint64){
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{
    uint96 public constant  FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            
            ,
            ,
            address vrfCoordinator,
            ,
            uint64 subId
            ,
            
        ) = helperConfig.activeNetworkConfig();
        

    }



    function run() external{
        fundSubscriptionUsingConfig();
    }
}