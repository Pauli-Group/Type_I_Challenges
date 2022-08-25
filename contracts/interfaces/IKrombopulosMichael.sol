pragma solidity ^0.8.1;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "../Puzzle.sol";
import "../Challenge.sol";
import "../Solution.sol";
import "../Message.sol";
import "../DataPoint.sol";
import "../Sponsorship.sol";

/**
    summery of the type I challenges... code name: Krombopulos Michael
 */
interface IKrombopulosMichael is IERC721, IERC2981 {
    // events
    event ChallengesPostedEvent(uint256 indexed new_max_challenge_index);
    event MintEvent(uint256 indexed challenge_position, uint256 indexed token_id);

    // BroadcastFacet
    function addMessage(string memory message) external;

    function getMessage(uint256 index) external view returns (Message memory);

    function getMessageText(uint256 index) external view returns (string memory);

    function getMessageIndex() external view returns (uint256);

    function getAllMessages() external view returns (Message[] memory);

    function getAllMessagesText() external view returns (string[] memory);

    // MintFacet
    function checkSolution(
        bytes32 hMessage,
        bytes memory sigProof,
        uint256 challengeIndex
    ) external view returns (bool);

    function mint(
        bytes32 hMessage,
        bytes memory proofSig,
        uint256 challengeIndex,
        string memory playerName
    ) external;

    // ScoreboardFacet
    function getAllSolutions() external view returns (Solution[] memory solutions);

    function getDataPoints() external view returns (DataPoint[] memory);

    // ChallengeManagerFacet
    function postNewChallenges(Puzzle[] memory puzzles, bytes[] calldata proofSigs) external;

    function getChallenge(uint256 challengeIndex) external view returns (Challenge memory);

    function getAllChallenges() external view returns (Challenge[] memory);

    function isChallengePaused(uint256 challengeIndex) external view returns (bool);

    // ownership
    function transferOwnership(address _newOwner) external;

    function owner() external view returns (address owner_);

    // royalties
    function setRoyaltyRate(uint32 _royaltyRate) external;

    function setRoyaltyReceiver(address _royaltyAddress) external;

    // token info
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function setNameAndSymbol(string memory _name, string memory _symbol) external;

    // token uri
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function getBaseURI() external view returns (string memory);

    function setBaseURI(string memory) external;

    // sponsorship
    function sponsor(
        uint256 position,
        string memory sponsorName,
        string memory sponsorMessage
    ) external payable returns (bool);

    // svg
    function svg(uint256 challenge_position) external view returns (string memory);

    // Search Tokens
    function byOwner(address tk_owner) external view returns (uint256, uint256[] memory);

    function bySolver(address tk_solver) external view returns (uint256, uint256[] memory);

    function get_solver_by_tokenId(uint256 token_id) external view returns (address);

    function get_solver_name_by_tokenId(uint256 token_id) external view returns (string memory);

    function get_data_by_tokenId(uint256 token_id) external view returns (string memory);

    function get_amount_solved_by_solver(address tk_solver) external view returns (uint256);

    function get_challenge_index_by_tokenId(uint256 token_id) external view returns (uint256);

    function get_sponsorships_by_challengeId(uint256 challengePosition) external view returns (Sponsorship[] memory);

    function get_sponsorships_by_tokenId(uint256 token_id) external view returns (Sponsorship[] memory);

    function get_max_challenge_index() external view returns (uint256);
}
