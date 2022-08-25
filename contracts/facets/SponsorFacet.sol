// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../Challenge.sol";
import "../HelpECDSA.sol";
import "../Sponsorship.sol";

/*
    SponsorFacet.sol
    William Doyle
    July 5th 2022

    This is a facet that allows a sponsor to sponsor a challenge. The sponsor can specify the following parameters:
        1. the currency they want to give as a sponsor
        2. the amount of currency they want to give as a sponsor
        3. the name of the sponsor
        4. a short message from the sponsor
        5. the position of the challenge to sponsor
*/
contract SponsorFacet is ReentrancyGuard, Context {

    function sponsor(uint256 position, string memory sponsorName, string memory sponsorMessage) public payable nonReentrant returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        // 1. ensure the position is valid
        require(ds.challenge_records.max_challenge_index >= position, "position is out of bounds");

        // 2. ensure the sponsors name is under N bytes
        require(bytes(sponsorName).length <= ds.state_records.name_size, "Sponsor's name is too long");

        // 3. ensure the sponsors message is under M bytes
        require(bytes(sponsorMessage).length <= ds.state_records.message_size, "Sponsor's message is too long");

        // 4. ensure msg.value is greater than minimum sponsor amount
        require(msg.value > 3000000000000000000, "Sponsorship must be greater than 3000000000000000000 wei");

        // calculate the address of the challange to sponsor
        // a. find the challenge
        Challenge memory challenge = ds.challenge_records.challenges[position];
        address addr = HelpECDSA.calculateAddress( challenge.currentPuzzle.publicKey );

        // b. create the sponsorship record
        Sponsorship memory sponsorship = Sponsorship(sponsorName, sponsorMessage, msg.value, block.number);

        // c. find out how many sponsors there are for this challenge already
        uint256 numSponsors = ds.sponsorship_records.challenge_position_to_sponsorship_count[position];

        // d. add the sponsorship to the list of sponsors for this challenge
        ds.sponsorship_records.challenge_position_to_sponsorships[position][numSponsors] = sponsorship;
        ds.sponsorship_records.challenge_position_to_sponsorship_count[position]++;

        // send the msg.value to addr
        uint256 amount_for_challenge = msg.value - ((msg.value * ds.royalty_records.royalty_rate) / 10000);
        uint256 amount_for_pauligroup = msg.value - amount_for_challenge;

        // payable(addr).transfer(msg.value);
        payable(addr).transfer(amount_for_challenge);
        payable(ds.royalty_records.royalty_receiver).transfer(amount_for_pauligroup);

        return true;
    }
}