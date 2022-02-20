pragma solidity >=0.4.22 <0.8.0;

contract SimplePaymentChannel {
    address public sender;     // The account sending payments.
    address public recipient;  // The account receiving the payments.
    uint256 public expiration; // Timeout in case the recipient never closes.

    function PaymentChannel(address _recipient, uint256 duration)
        public
        payable
    {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function isValidSignature(uint256 amount, bytes signature)
        internal
        view
        returns (bool)
    {
        bytes32 message = prefixed(keccak256(this, amount));

        // Check that the signature is from the payment sender.
        return recoverSigner(message, signature) == sender;
    }

    // The recipient can close the channel at any time by presenting a signed
    // amount from the sender. The recipient will be sent that amount, and the
    // remainder will go back to the sender.
    function close(uint256 amount, bytes signature) public {
        require(msg.sender == recipient);
        require(isValidSignature(amount, signature));

        recipient.transfer(amount);
        selfdestruct(sender);
    }


    // If the timeout is reached without the recipient closing the channel, then
    // the ether is released back to the sender.
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

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256("\x19Ethereum Signed Message:\n32", hash);
    }
}



contract Switches {
    
	address public addressA=0x1234;
	address public addressB=0x2345;
	address public addressC=0x3457;
    uint channel;
    uint rankA;
    uint rankB;
    uint rankC;
    SimplePaymentChannel pc;
    
    function Switches(address addr, uint32 channel, uint32 senderSig) public returns (uint wallet) {
    assembly {
        switch addr()
            case 0x1234 {
                switch channel 
                    case 5 {
                        pc.PaymentChannel(0x1234, 100);
                        pc.isValidSignature(5, senderSig);
                        pc.close(5, 0x2345);
                        rankA=rankA+1;
                        break;
                    }
                    
                    case 10 {
                       pc.PaymentChannel(0x1234, 100);
                        pc.isValidSignature(10, senderSig);
                        pc.close(5, 0x2345);
                        rankA=rankA+1;
                        break;
                    }
                    
                    default {
                        ChannelTimeout(100);
                    }
                    
            }
            case addressB {
                switch channel 
                    case 5 {
                        pc.PaymentChannel(0x1234, 100);
                        pc.isValidSignature(5, senderSig);
                        pc.close(5, 0x2345);
                        rankB=rankB+1;
                        break;
                    }
                    
                    case 3 {
                        pc.PaymentChannel(0x1234, 100);
                        pc.isValidSignature(3, senderSig);
                        pc.close(3, 0x2345);
                        rankB=rankB+1;
                        break;
                    }
                    
                    default {
                        ChannelTimeout(100);
                    }
                    
            }
            default {
                ChannelTimeout(100);
            }
        
    }
    }
}
