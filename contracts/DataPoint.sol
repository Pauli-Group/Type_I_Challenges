// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

/*
    Datapoint.sol
    June 8th 2022
    William Doyle
    All the data relevent to the graph (scoreboard)

    WARNING: WHEN ADDING NEW FIELDS TO THIS FILE, YOU MUST ADD THEM TO THE END OF THE STRUCT...
    OTHERWISE YOU WILL RUIN THE STRUCTURE THE CLIENT EXPECTS!

*/

import "./Challenge.sol";
import "./Solution.sol";

struct DataPoint {
    Challenge challenge;
    Solution solution;
    address owner;
    address solver;
    string solver_name;
    uint256 tokenId;
}