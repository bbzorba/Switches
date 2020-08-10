pragma solidity >=0.4.22 <0.8.0;

contract Switches {

	address public addressA;
	address public addressB;
	address public addressC;
	mapping (bytes32 => address) signatures;

function Switches()
    {
    switch (address)
        case 0 {
            
        }
        default {
            
        }
    }



    contract Channel {
        address public sender;     // sender's address
        address public recipient;  // recipient's address
        uint256 public expiration; // Timeout
    
        function PaymentChannel(address _recipient, uint256 duration)
            public
            payable
        {
            sender = msg.sender;
            recipient = _recipient;
            expiration = now + duration;
        }
    
        function VerifySignature(uint256 amount, bytes signature)
            internal
            view
            returns (bool)
        {
            bytes32 message = prefixed(keccak256(this, amount));
    
            return recoverSigner(message, signature) == sender;
        }
    
        function close(uint256 amount, bytes signature) public {
            require(msg.sender == recipient);
            require(VerifySignature(amount, signature));
    
            recipient.transfer(amount);
            selfdestruct(sender);
        }
    
        // The sender can extend the expiration at any time.
        function extend(uint256 newExpiration) public {
            require(msg.sender == sender);
            require(newExpiration > expiration);
    
            expiration = newExpiration;
        }
    
    
        function claimTimeout() public {
            require(now >= expiration);
            selfdestruct(sender);
        }
    
        function splitSignature(bytes sig)
            internal
            pure
            returns (uint8, bytes32, bytes32)
        {
            require(sig.length == 65);
    
            bytes32 r;
            bytes32 s;
            uint8 v;
    
            assembly {
                // first 32 bytes, after the length prefix
                r := mload(add(sig, 32))
                // second 32 bytes
                s := mload(add(sig, 64))
                // final byte (first byte of the next 32 bytes)
                v := byte(0, mload(add(sig, 96)))
            }
    
            return (v, r, s);
        }
    
        function recoverSigner(bytes32 message, bytes sig)
            internal
            pure
            returns (address)
        {
            uint8 v;
            bytes32 r;
            bytes32 s;
    
            (v, r, s) = splitSignature(sig);
    
            return ecrecover(message, v, r, s);
        }
        
    }

}
