// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../Challenge.sol";
import "../HelpECDSA.sol";
import "../Sponsorship.sol";
import "../PauliGroupBase.sol";

contract AdminFacet is PauliGroupBase {

    /**
        setNameSize
        William Doyle
        July 18th 2022
     */
    function setNameSize (uint32 _nameSize) public onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.state_records.name_size = _nameSize;
    }

    /**
        setMessageSize
        William Doyle
        July 18th 2022
     */
    function setMessageSize (uint32 _messageSize) public onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.state_records.message_size = _messageSize;
    }

}