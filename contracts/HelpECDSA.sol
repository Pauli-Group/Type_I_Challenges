// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library HelpECDSA {
    /*
      VerifyMessage
      takes a signature and the hash of a message and returns the address of the signer
      William Doyle
      May 9th 2020
    */
    function VerifyMessage(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function VerifyMessage(bytes32 hMessage, bytes memory rawsig)
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(rawsig, 32))
            s := mload(add(rawsig, 64))
            v := and(mload(add(rawsig, 65)), 255)
        }
        if (v < 27) v += 27;
        return VerifyMessage(hMessage, v, r, s);
    }

    function VerifyMessage(Sig memory sig) public pure returns (address) {
        return VerifyMessage(sig.messageHash, sig.v, sig.r, sig.s);
    }

    function RecoverPublicKey(Sig memory sig) public pure returns (bytes32) {
        // todo: implement this somehow
    }

    /*
        calculateAddress :: PublicKey -> Address
        calculate the address of a public key
        William Doyle
        May 10th 2022
    */
    function calculateAddress(bytes memory publicKey)
        public
        pure
        returns (address)
    {
        require(publicKey.length == 64);
        return address(bytes20(uint160(uint256(keccak256(publicKey)))));
    }

    /*
        calculatePublicKey :: PrivateKey -> PublicKey
        William Doyle
        May 10th 2022 
    */
    function calculatePublicKey(bytes32 privateKey)
        public
        pure
        returns (bytes memory)
    {
        // I want to do this but I need to check with Pierre-Luc to make sure the development time is worth it, or if he's okay
        // checking the private key with a sha256 hash
        // this could go two ways, I could find a way to calculate the public key in solidity by doing research,
        // or I could translate some C or C++ code to calculate the public key into solidity
        // I will look more into this once I have all the easy stuff done
    }

    /*
        An ECDSA signature.
        Along with r and s we also include v, and the hash of the message
        I plan to phase this out in favor of simple processing the raw signature (bytes)
    */
    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
        bytes32 messageHash;
    }
}
