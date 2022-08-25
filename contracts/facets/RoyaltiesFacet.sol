// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

// import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";

import "../PauliGroupBase.sol";

contract RoyaltiesFacet is PauliGroupBase {
    /*
        royaltyInfo
        William Doyle
        EIP-2981
    */
    function royaltyInfo(uint256, uint256 salePrice) external view returns (address, uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return (ds.royalty_records.royalty_receiver, (salePrice * ds.royalty_records.royalty_rate) / 10000);
    }

    function setRoyaltyRate(uint32 _royaltyRate) external onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.royalty_records.royalty_rate = _royaltyRate;
    }

    /**
        setRoyaltyReceiver
        William Doyle
        July 18th 2022

        specify the address where the royalties will be sent
     */
    function setRoyaltyReceiver(address _royaltyAddress) external onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.royalty_records.royalty_receiver = _royaltyAddress;
    }
}
