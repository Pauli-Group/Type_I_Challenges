// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../PauliGroupBase.sol";
import "../Challenge.sol";
import "../StringHelper.sol";

// @todo: finish this
contract SvgFacet is PauliGroupBase {
 
    /*
        William Doyle
        svg
        July 8th 2022    
    */
    function svg(uint256 challenge_position) public view returns (string memory svg_image) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challenge_position <= ds.challenge_records.max_challenge_index, "challenge_position out of bounds");

        svg_image = "";

        svg_image = StringHelper.appendString(
            '<svg height="30" width="200"><text x="0" y="15" fill="red">',
            StringHelper.appendString("position: ", Strings.toString(challenge_position), ""),
            "</text></svg>"
        );
    }

   
}
