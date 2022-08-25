// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "./Puzzle.sol";

/*
        An object used to indicate the successful solving of an ECDSA puzzle. To be used as meta data for the minted tokens.
        William Doyle
    */
struct Solution {
    address solvedBy; // address of the person who solved the puzzle
    Puzzle puzzle;
    uint postedAt; // timestamp of when the puzzle was posted
    uint solvedAt; // timestamp of when the puzzle was solved
    string solverName; // name of the person who solved the puzzle
}
