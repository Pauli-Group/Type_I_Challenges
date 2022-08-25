// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/*
    WARNING: WHEN ADDING NEW FIELDS TO THIS FILE, YOU MUST ADD THEM TO THE END OF THE STRUCT...
    OTHERWISE YOU WILL RUIN THE STRUCTURE THE CLIENT EXPECTS!
*/
struct Puzzle {
    bytes publicKey;
    bytes32 knownBytes;
}
