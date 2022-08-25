// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "../HelpECDSA.sol";
import "../Puzzle.sol";
import "../Solution.sol";
import "../StringHelper.sol";
import "../PauliGroupBase.sol";

contract MintFacet is ReentrancyGuard, Context, PauliGroupBase {
    using Address for address;
    /*
        modifier: onlyWhenLive
        allow pausing of individual challenges
        William Doyle
        May 24th 2022
    */
    modifier onlyWhenLive(uint256 challengeIndex) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex <= ds.challenge_records.max_challenge_index);
        require(!ds.challenge_records.challengeFrozen[challengeIndex]);
        _;
    }

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function _getPuzzle(uint256 challengeIndex) private view returns (Puzzle memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex < ds.challenge_records.challenges.length);
        return ds.challenge_records.challenges[challengeIndex].currentPuzzle;
    }

    /*
          check solution
          William Doyle
    */
    function checkSolution(
        bytes32 hMessage,
        bytes memory sigProof,
        uint256 challengeIndex
    ) external view returns (bool) {
        return _checkSolution(hMessage, sigProof, challengeIndex);
    }

    /*
        avoid using this.f() syntax in mint() --> https://ethereum.stackexchange.com/questions/19380/external-vs-public-best-practices
        William Doyle
        June 2nd 2022
    */
    function _checkSolution(
        bytes32 hMessage,
        bytes memory sigProof,
        uint256 challengeIndex
    ) private view returns (bool) {
        // signed message must be address of sender
        require(hMessage == keccak256(bytes(abi.encodePacked(msg.sender))), "hMessage should be hash of sender address");
        // signed message must be signed with the challange private key
        require(
            HelpECDSA.calculateAddress(_getPuzzle(challengeIndex).publicKey) == HelpECDSA.VerifyMessage(hMessage, sigProof),
            "Signature not for current problem"
        );
        return true;
    }

    /*
      mint
      Mints a new token upon a valid solution being provided. A valid solution is a signature made by one of the puzzle wallets. 
      The signature's message must be the address of the callers wallet. This mint function allways mints to the caller's wallet.
      William Doyle
      May 10th 2022
    */
    function mint(
        bytes32 hMessage,
        bytes memory proofSig,
        uint256 challengeIndex
    ) public {
        _mint(hMessage, proofSig, challengeIndex, StringHelper.toAsciiString(msg.sender)); // if no name provided, use address of caller
    }

    function mint(
        bytes32 hMessage,
        bytes memory proofSig,
        uint256 challengeIndex,
        string memory playerName
    ) public {
        _mint(hMessage, proofSig, challengeIndex, playerName); // if no name provided, use address of caller
    }

    /*
        _mint
        code required to mint a new token upon a valid solution being provided. A valid solution is a signature made by one of the puzzle wallets.
    */
    function _mint(
        bytes32 hMessage,
        bytes memory proofSig,
        uint256 challengeIndex,
        string memory playerName
    ) private onlyWhenLive(challengeIndex) nonReentrant {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(challengeIndex < ds.challenge_records.challenges.length, "Challenge index out of bounds");
        require(_checkSolution(hMessage, proofSig, challengeIndex), "Solution is not valid. checkSolution failed");
        require(bytes(playerName).length <= ds.state_records.name_size, "Player name is too long");

        uint256 id = ds.nft_records.next_token_id; 
        ds.nft_records.token_id_to_owner[id] = msg.sender;
        ds.nft_records.token_id_to_solver[id] = msg.sender;

        ds.nft_records.token_id_to_solver_name[id] = playerName;
        ds.nft_records.token_id_to_challenge_index[id] = challengeIndex;

        ds.token_id_to_solution[id] = Solution(
            msg.sender,
            _getPuzzle(challengeIndex),
            ds.challenge_records.challenges[challengeIndex].timestamp,
            block.timestamp,
            playerName
        );
        ds.challenge_records.challengeFrozen[challengeIndex] = true;

        ds.nft_records.next_token_id++;
        ds.nft_records.owner_to_balance[msg.sender]++;
        ds.nft_records.solver_to_amount_solved[msg.sender]++;

        emit Transfer(address(0), msg.sender, id);
        emit MintEvent(challengeIndex, id);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(owner != address(0), "ERC721: balance query for the zero address");
        return ds.nft_records.owner_to_balance[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address owner = ds.nft_records.token_id_to_owner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.nft_records.tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(
        address to,
        uint256 tokenId // override
    ) public virtual {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.token_id_to_owner[tokenId] != address(0);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        returns (
            // override
            address
        )
    {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records.tokenApprovals[tokenId];
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.nft_records._operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(
        address operator,
        bool approved // override
    ) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        returns (
            // override
            bool
        )
    {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.nft_records._operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.nft_records.owner_to_balance[from] -= 1;
        ds.nft_records.owner_to_balance[to] += 1;
        ds.nft_records.token_id_to_owner[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId // override
    ) public virtual {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId // override
    ) public virtual {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data // override
    ) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    // function supportsInterface(bytes4 interfaceId) external view returns (bool){
    //     LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    //     return ds.supportedInterfaces[interfaceId];
    // }
}
