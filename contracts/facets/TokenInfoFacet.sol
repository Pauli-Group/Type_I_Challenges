// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../PauliGroupBase.sol";

contract TokenInfoFacet is PauliGroupBase {

     /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records._name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records._symbol;
    }

    function setNameAndSymbol(string memory _name, string memory _symbol) public onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.nft_records._name = _name;
        ds.nft_records._symbol = _symbol;
    }
}