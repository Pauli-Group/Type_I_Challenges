// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Puzzle.sol";

/*
        Challenge structure
        William Doyle
        A challange can be thought of as a container for a puzzle. You put a puzzle in a challange
        and when the puzzle is solved a new puzzle is placed in the challange. 

    WARNING: WHEN ADDING NEW FIELDS TO THIS FILE, YOU MUST ADD THEM TO THE END OF THE STRUCT...
    OTHERWISE YOU WILL RUIN THE STRUCTURE THE CLIENT EXPECTS!

    */
struct Challenge {
    bytes32 id;
    Puzzle currentPuzzle; // TODO: rename to `puzzle`
    uint timestamp;
    uint256 position; // the index of this challenge (maybe redundent but makes the front end easier (posting solutiuons requires the user provide the id of the challenge they are solving. If I just use the index of the returned results then sorting and filtering gets complicated))
}
