// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../Sponsorship.sol";

contract SearchTokensFacet {
    /*
        byOwner :: address -> (uint256, uint256[])
        takes an address and returns the number of tokens owned by that address followed by a list of all the token ids owned by that address
        July 12th 2022
        William Doyle
    */
    function byOwner(address tk_owner) public view returns (uint256, uint256[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // // check balance of tk_owner
        uint256 tk_owner_balance = ds.nft_records.owner_to_balance[tk_owner];

        uint256[] memory token_ids = new uint256[](tk_owner_balance);
        uint256 amountFound = 0;
        for (uint256 i = 0; i < ds.nft_records.next_token_id; i++)
            if (ds.nft_records.token_id_to_owner[i] == tk_owner) {
                token_ids[amountFound] = i;
                amountFound++;
                if (amountFound > tk_owner_balance) break;
            }

        return (tk_owner_balance, token_ids);
    }

    /*
        bySolver:: address -> (uint256, uint256[])
        takes an address and returns the number of challenges solved by that address followed by a list of all the token ids assosiated with those solutions
        July 12th 2022
        William Doyle
    */
    function bySolver(address tk_solver) public view returns (uint256, uint256[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 amountSolved = ds.nft_records.solver_to_amount_solved[tk_solver];

        uint256[] memory token_ids = new uint256[](amountSolved);
        uint256 amountFound = 0;
        for (uint256 i = 0; i < ds.nft_records.next_token_id; i++)
            if (ds.nft_records.token_id_to_owner[i] == tk_solver) {
                token_ids[amountFound] = i;
                amountFound++;
                if (amountFound > amountSolved) break;
            }

        return (amountSolved, token_ids);
    }

    /**
        get_solver_by_tokenId :: uint256 -> address
        takes a token id and returns the address of the solver that solved the associated challenge
        William Doyle
        July 19th 2022

        TESTED: NO
     */
    function get_solver_by_tokenId(uint256 token_id) public view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.token_id_to_solver[token_id];
    }

    /**
        get_solver_name_by_tokenId :: uint256 -> string
        takes a token id and returns the name of the solver that solved the associated challenge 
        William Doyle
        July 19th 2022

        TESTED: NO
     */
    function get_solver_name_by_tokenId(uint256 token_id) public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.token_id_to_solver_name[token_id];
    }

    /**
        get_data_by_tokenId :: uint256 -> string
        takes a token id and returns the data associated with the token
        William Doyle
        July 19th 2022

        TESTED: NO
     */
    function get_data_by_tokenId(uint256 token_id) public view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.token_id_to_data[token_id];
    }

    /** 
        get_amount_solved_by_solver :: address -> uint256
        takes an address and returns the number of challenges solved by that address
        William Doyle
        July 19th 2022

        TESTED: NO
      */
    function get_amount_solved_by_solver(address tk_solver) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.solver_to_amount_solved[tk_solver];
    }

    /**
        get_challenge_index_by_tokenId :: uint256 -> uint256
        takes a token id and returns the position of the associated challenge in the list of challenges
        William Doyle
        July 19th 2022

        TESTED: NO
       */
    function get_challenge_index_by_tokenId(uint256 token_id) public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.token_id_to_challenge_index[token_id];
    }

    /**
        get_sponsorships_by_challengeId :: uint256 -> Sponsorship[]
        takes a challenge id and returns the list of sponsorships associated with that challenge
        William Doyle
        July 19th 2022

        TESTED: NO 
        */
    function get_sponsorships_by_challengeId(uint256 challengePosition) public view returns (Sponsorship[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 amount_sponsorships = ds.sponsorship_records.challenge_position_to_sponsorship_count[challengePosition];

        Sponsorship[] memory sponsorships = new Sponsorship[](amount_sponsorships);
        for (uint256 i = 0; i < amount_sponsorships; i++)
            sponsorships[i] = ds.sponsorship_records.challenge_position_to_sponsorships[challengePosition][i];

        return sponsorships;
    }

    /**
        get_sponsorship_by_tokenId :: uint256 -> Sponsorship
        takes a token id and returns the sponsorship associated with that token
        William Doyle
        July 19th 2022

        TESTED: NO
       */
    function get_sponsorships_by_tokenId(uint256 token_id) public view returns (Sponsorship[] memory) {
        uint256 challengePosition = get_challenge_index_by_tokenId(token_id);
        return get_sponsorships_by_challengeId(challengePosition);
    }


    /**
        get_max_challenge_index :: uint256
        William Doyle
        July 25th 2022
     */
    function get_max_challenge_index() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.challenge_records.max_challenge_index;
    }

    /**
        totalSupply :: uint256
        William Doyle
        April 17th 2022
     */
     function totalSupply() public view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        uint256 num_minted = ds.nft_records.next_token_id;
        uint256 num_owned_by_null = ds.nft_records.owner_to_balance[address(0)];

        return num_minted - num_owned_by_null;
     }
}
