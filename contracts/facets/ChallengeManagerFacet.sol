// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/*
    ChallengeManagerFacet.sol
    June 1st 2022
    William Doyle
*/

import "@openzeppelin/contracts/utils/Strings.sol";
import "../Puzzle.sol";
import "../Challenge.sol";

// import "../PauliGroupTypes.sol";
import "../StringHelper.sol";
import "../HelpECDSA.sol";

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../PauliGroupBase.sol";

contract ChallengeManagerFacet is PauliGroupBase {
    /*
        postNewChallenges
        Append a new list of challenges to the list of challenges
        William Doyle
        May 25th 2022
    */
    function postNewChallenges(
        Puzzle[] memory puzzles, 
        bytes[] calldata proofSigs
    ) external onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 mci_at_start = ds.challenge_records.max_challenge_index;

        bytes32 hMessage = keccak256(bytes(abi.encodePacked(msg.sender)));

        for (; ds.challenge_records.max_challenge_index - mci_at_start < (puzzles.length); ds.challenge_records.max_challenge_index++) {
            bytes32 challengeId = keccak256(bytes(StringHelper.appendString( Strings.toString(block.number), Strings.toString(ds.challenge_records.max_challenge_index),"williamdoyle")));

            bytes memory puz_pk = puzzles[ds.challenge_records.max_challenge_index - mci_at_start].publicKey;
            bytes memory s = proofSigs[ds.challenge_records.max_challenge_index - mci_at_start];

            address addressFromSig = HelpECDSA.VerifyMessage(hMessage, s);
            address addressFromPub = HelpECDSA.calculateAddress(puz_pk);

            require(addressFromSig == addressFromPub, "Each puzzle needs a corresponding signature");

            ds.challenge_records.challenges.push(Challenge(challengeId, puzzles[ds.challenge_records.max_challenge_index - mci_at_start], block.timestamp, ds.challenge_records.challenges.length));
        }

        emit ChallengesPostedEvent(ds.challenge_records.max_challenge_index);
    }

    function getChallenge(uint256 challengeIndex) external view returns (Challenge memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex <= ds.challenge_records.max_challenge_index, "challengeIndex out of bounds");
        return ds.challenge_records.challenges[challengeIndex];
    }

    function getAllChallenges() external view returns (Challenge[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.challenge_records.challenges;
    }

    // untested
    function isChallengePaused(uint256 challengeIndex) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex <= ds.challenge_records.max_challenge_index, "challengeIndex out of bounds");
        return ds.challenge_records.challengeFrozen[challengeIndex];
    }

    function _getPuzzle(uint256 challengeIndex) private view returns (Puzzle memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex < ds.challenge_records.challenges.length);
        return ds.challenge_records.challenges[challengeIndex].currentPuzzle;
    }
}
