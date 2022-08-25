// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibDiamond } from "../libraries/LibDiamond.sol";
import "../PauliGroupBase.sol";
import "../Message.sol";

/*
    Owner of diamond can post a new message whenever they want.
    We can use this for announcments or other public messages.
    William Doyle
*/
contract BroadcastFacet is PauliGroupBase {

    /*
        Add a message to the message list
    */
    function addMessage(string memory message) external onlyDiamondOwner {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.broadcast_records.messages[ds.broadcast_records.message_index] = Message(message, block.timestamp);
        ds.broadcast_records.message_index++;
    }

    /*
        Get a message from the message list
    */
    function getMessage(uint256 index) external view returns (Message memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.broadcast_records.messages[index];
    }

    /*
        Get just the message
    */
    function getMessageText(uint256 index) external view returns (string memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.broadcast_records.messages[index].message;
    }

    /*
        Get the number of messages in the message list
    */
    function getMessageIndex() external view returns (uint256) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.broadcast_records.message_index;
    }

    /*
        get every message in the message list
    */
    function getAllMessages() external view returns (Message[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        Message[] memory messages = new Message[](ds.broadcast_records.message_index);
        for (uint256 i = 0; i < ds.broadcast_records.message_index; i++) 
            messages[i] = ds.broadcast_records.messages[i];
        return messages;
    }

    /*
        get all messages but just the message
    */
    function getAllMessagesText() external view returns (string[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        string[] memory messages = new string[](ds.broadcast_records.message_index);
        for (uint256 i = 0; i < ds.broadcast_records.message_index; i++) 
            messages[i] = ds.broadcast_records.messages[i].message;
        return messages;
    }
}