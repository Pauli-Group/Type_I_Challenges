// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    a base contract for all facets to inherit from
*/

import {LibDiamond} from "./libraries/LibDiamond.sol";

contract PauliGroupBase {

    /**
        onlyDiamondOwner
        William Doyle
     */
    modifier onlyDiamondOwner() {
        require(msg.sender == LibDiamond.diamondStorage().contractOwner, "You are not the owner of this contract.");
        _;
    }

    /**
        MintEvent
        William Doyle
        July 18th 2022
        Indicate that a challenge has been solved. Include the id of the challenge
        and the id of the minted token.
     */    
    event MintEvent(uint256 indexed challenge_position, uint256 indexed token_id);

    /**
        ChallengesPostedEvent
        William Doyle
        July 18th 2022
        Indicate that new challenges have been posted. Indicate the new amount of challenges
        hosted on this contract. 
     */
    event ChallengesPostedEvent(uint256 indexed new_max_challenge_index);

}
