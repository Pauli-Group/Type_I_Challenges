// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../PauliGroupBase.sol";
import "../StringHelper.sol";

contract TokenURIFacet is PauliGroupBase {

    /**
        tokenURI
        William Doyle
        Takes a token id and returns a URI of a json file (hopefully) containing the relevent metadata for the token.
     */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(_tokenId < ds.nft_records.next_token_id, "tokenId out of bounds");

        string memory __chain_id__ = Strings.toString(block.chainid);
        string memory __contract_address__ = StringHelper.toAsciiString(address(this));

        uint256 challengePosition = ds.nft_records.token_id_to_challenge_index[_tokenId];

        return StringHelper.appendString(
                ds.state_records.base_uri,
                __chain_id__,
                "_",
                __contract_address__,
                "_",
                Strings.toString(challengePosition),
                "_metadata.json",
                "?alt=media",
                ""
            );
    }


    /**
        getBaseURI
        William Doyle
        July 21st 2022
     */
    function getBaseURI () public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.state_records.base_uri;
    }

    /**
        setBaseURI
        William Doyle
        July 21st 2022
     */
     function setBaseURI (string memory _baseURI) public onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.state_records.base_uri = _baseURI;
     }
}
