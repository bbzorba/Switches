pragma solidity >=0.4.22 <0.8.0;

contract Switches {
    
    address public addr;
	address public addressA;
	address public addressB;
	address public addressC;
	mapping (bytes32 => address) signatures;
	uint32 public channel;

function Switches(address addr, channel)
    {
    switch addr
        case addressA {
            Payment(addressA,100);
            switch (channel)
                case 
                    CloseChannel(h,v,r,s,10); //10 ETH channel
                    ChannelTimeout();
                    
                    
        }
        case addressB {
            
        }
        default {
            
        }
    }


    
    contract PaymentChannel {
    
    	address public channelSender;
    	address public channelRecipient;
    	uint public channelBegin;
    	uint public channelTimeout;
    	mapping (bytes32 => address) signatures;
    
    	function Payment(address receiver, uint timeout) 
	public payable {
    		channelRecipient = receiver;
    		channelSender = msg.sender;
    		channelBegin = now;
    		channelTimeout = timeout;
    	}
    
    	function CloseChannel(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value){
    
    		address signer;
    		bytes32 proof;
    
    		// get from signature
    		signer = ecrecover(h, v, r, s);
    
    		// signature is invalid, throw
    		if (signer != channelSender && signer != channelRecipient) throw;
    
    		proof = sha3(this, value);
    
    		// signature is valid but doesn't match the data provided
    		if (proof != h) throw;
    
    		if (signatures[proof] == 0)
    			signatures[proof] = signer;
    		else if (signatures[proof] != signer){
    			// channel completed, both signatures provided
    			if (!channelRecipient.send(value)) throw;
    			selfdestruct(channelSender);
    		}
    
    	}
    
    	function ChannelTimeout(){
    		if (channelBegin + channelTimeout > now)
    			throw;
    
    		selfdestruct(channelSender);
    	}
    
    }
}
