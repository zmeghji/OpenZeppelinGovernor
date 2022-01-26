// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TimelockController.sol";

contract MyTimelockController is TimelockController{
    constructor(
        uint minDelay,
        address[] memory proposers,
        address[] memory executors
    )
        TimelockController(minDelay, proposers, executors)    
    {

    }
}