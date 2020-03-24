pragma solidity ^0.5.16;

contract VerifySignature {
    // TODO:
    // https://solidity.readthedocs.io/en/v0.6.3/solidity-by-example.html#micropayment-channel
    // https://programtheblockchain.com/posts/2018/02/17/signing-and-verifying-messages-in-ethereum/
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/cryptography/ECDSA.sol
    // ethereum.enable()

    // web3.sha3("hello world")
    // hash = "0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad"

    // web3.personal.sign(hash, web3.eth.defaultAccount, console.log)
    // 0x8f00192668d6b3594d34fd8a7df125b961f0295a79093c0d38d068b0f8a1d6477d2800e935416a9c0dafdf00c0ee72b085677b50f57571c56398392f1c05e2231c
    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    // Signature is produced by signing a hash with the following format:
    // - prefix of "\x19Ethereum Signed Message\n"
    // - length of message
    // - actual message
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        // NOTE: \n32 since _hash is 32 length
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    /*
    hash
    getHash(0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad)
    0x93100cc9477ba6522a2d7d5e83d0e075b167224ed8aa0c5860cfd47fa9f22797
    sig
    0x8f00192668d6b3594d34fd8a7df125b961f0295a79093c0d38d068b0f8a1d6477d2800e935416a9c0dafdf00c0ee72b085677b50f57571c56398392f1c05e2231c
    */
    // If the signature or hash is valid the function will return
    // the address of the signer, otherwise a zero address.
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        // Splitting the signature
        // TODO: explain v, r, s
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(_signature);

        // TODO: why hash before signing?
        // TODO: why eth prefix before signing?
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        // TODO: explain assembly
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s:= mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}