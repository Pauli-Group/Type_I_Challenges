// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

/*
    ScoreboardFacet.sol
    June 1st 2022
    William Doyle
*/

import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../Solution.sol";
import "../DataPoint.sol";

contract ScoreboardFacet {
    function getAllSolutions() external view returns (Solution[] memory solutions) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        solutions = new Solution[](ds.nft_records.next_token_id);
        for (uint256 i = 0; i < ds.nft_records.next_token_id; i++) 
        solutions[i] = ds.token_id_to_solution[i];
    }

    function getDataPoints() external view returns (DataPoint[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        DataPoint[] memory dataPoints = new DataPoint[](ds.nft_records.next_token_id);
        for (uint256 i = 0; i < ds.nft_records.next_token_id; i++)
            dataPoints[i] = DataPoint( ds.challenge_records.challenges[ds.nft_records.token_id_to_challenge_index[i]] , ds.token_id_to_solution[i], ds.nft_records.token_id_to_owner[i], ds.nft_records.token_id_to_solver[i], ds.nft_records.token_id_to_solver_name[i], i);
        return dataPoints;
    }
}
