## Proveably Random Raffle Contract

# About

**It creates proveably random smart contract lottery**

# To Do

1. User can purchase a ticket for lottery to enter/start.
    1. Ticket fees are going to go to winner during draw.
2. After x period of time winner is choosen programatically.
    1. Using chainlink Vrf & Chainlink Automation
        1. Chainlink VRF -> Randomness
        2. Chainlink Automation -> Time based trigger



# Explanation



*. Started with natspec i.e comments above the contract specifing title author etc.
*. defining function enterRaffle- for user to enter raffle i.e lottery and pickWinner.
    1. enterRaffle- 


# Learning:
*. Follow docs-
    Contract elements should be laid out in the following order:
    Pragma statements
    Import statements
    Events
    Errors
    Interfaces
    Libraries
    Contracts

    Inside each contract, library or interface, use the following order:
    Type declarations
    State variables
    Events
    Errors
    Modifiers
    Functions

    Functions should be grouped according to their visibility and ordered:
    constructor
    receive function (if exists)
    fallback function (if exists)
    external
    public
    internal
    private

*. require() uses more gas than custom error with conditional if statement
        1. Name the custom error as => ```contractname__errorname```
*. Event should be emitted whenever we update a storage variable.
    1. Why events-
        a. Makes migration easier
        b. makes front end indexing easier
    2. when emit is called the event log is created which consists of :-
        a. Address - address of the contract
        b. Name -  name of event and its parameters
        c. Topics - this contians the indexed part of event i.e all the variables that are defined as indexed are store here
        d. Data - all the non indexed vars are store here in hex format


*. CEI - Checks, Effects(Our own contract), Interations(Other Contracts)
*. Chainlink Automation
*. Deploy:-
    inherits Script.sol


