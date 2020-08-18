pragma solidity >=0.4.22 <0.8.0;

contract Switches {
    
	address public addressA;
	address public addressB;
	address public addressC;
    uint x = 5;
    uint y = 10;
    uint z = 1;
    uint channel;
    uint rankA;
    uint rankB;
    uint rankC;
    
    function Switches(address addr, uint32 channel){
        switch addr {
            case addressA {
                switch (channel) {
                    case x {
                        OpenChannel();
                        GetChannelId();
                        SendMsg();
                        VerifyMsg();
                        CloseChannel();
                        rankA++;
                    }
                    
                    case y {
                        OpenChannel();
                        GetChannelId();
                        SendMsg();
                        VerifyMsg();
                        CloseChannel();
                        rankA++;
                    }
                    
                    default {
                        ChannelTimeout();
                    }
                    
                }
            }
            case addressB {
                switch (channel) {
                    case x {
                        OpenChannel();
                        GetChannelId();
                        SendMsg();
                        VerifyMsg();
                        CloseChannel();
                        rankB++;
                    }
                    
                    case z {
                        OpenChannel();
                        GetChannelId();
                        SendMsg();
                        VerifyMsg();
                        CloseChannel();
                        rankB++;
                    }
                    
                    default {
                        ChannelTimeout();
                    }
                    
                }
            }
            default {
                ChannelTimeout();
            }
        }
    }


    
    contract PaymentChannel {
    
    	address public channelSender;
    	address public channelRecipient;
    	uint public channelBegin;
    	uint public channelTimeout;
    	mapping (bytes32 => address) signatures;
    
    	function OpenChannel(address token, address to, uint amount, uint timeout) payable {
    	    
            // Sanity checks
            if (amount == 0) { throw; }
            if (to == msg.sender) { throw; }
            if (active_ids[msg.sender][to] != bytes32(0)) { throw; }
            
            // Create a channel
            bytes32 id = sha3(msg.sender, to, now+timeout);
            
            // Initialize the channel
            Channel memory _channel;
            _channel.startDate = now;
            _channel.timeout = now+timeout;
            _channel.deposit = amount;
            _channel.sender = msg.sender;
            _channel.recipient = to;
            _channel.token = token;
            
            // Make the deposit
            ERC20 t = ERC20(token);
            if (!t.transferFrom(msg.sender, address(this), amount)) { throw; }
            channels[id] = _channel;
            
            // Add it to the lookup table
            active_ids[msg.sender][to] = id;
        }
        
        
        function GetChannelId(address from, address to) public constant returns (bytes32) {
            return active_ids[from][to];
        }
        
        
        function SendMsg(){
            var sha3 = require('solidity-sha3').default;
            var _value = 0.01*Math.pow(10, 18)    
            var value = _value.toString(16)    
            let _msg_hash = sha3(`0x${channel_id}`, _value);    
            let msg_hash = Buffer.from(_msg_hash.substr(2, 64), 'hex');     
            let sig = util.ecsign(msg_hash, keys.test.privateKey);    
            let parsed_sig = {      
                v: sig.v.toString(16),      
                r: sig.r.toString('hex'),      
                s: sig.s.toString('hex')    
            };    
            latest_value = value;    
            latest_sig = parsed_sig;    
            latest_msg_hash = msg_hash.toString('hex');
        }
        
        function VerifyMsg(bytes32[4] h, uint8 v, uint256 value) public constant returns (bool) {
            // h[0]    Channel id
            // h[1]    Hash of (id, value)
            // h[2]    r of signature
            // h[3]    s of signature
            // Grab the channel in question
            if (channels[h[0]].deposit == 0) { return false; }
            Channel memory _channel;
            _channel = channels[h[0]];
            address signer = ecrecover(h[1], v, h[2], h[3]);
            if (signer != _channel.sender) { return false; }
            // Proof that the value was hashed into the message
            bytes32 proof = sha3(h[0], value);
            
            // Ensure the proof matches
            if (proof != h[1]) { return false; }
            else if (value > _channel.deposit) { return false; }
            return true;
        }
        
        function CloseChannel(bytes32[4] h, uint8 v, uint256 value) {
            // h[0]    Channel id
            // h[1]    Hash of (id, value)
            // h[2]    r of signature
            // h[3]    s of signature
            // Grab the channel in question
            if (channels[h[0]].deposit == 0) { throw; }
            Channel memory _channel;
            _channel = channels[h[0]];
            if (msg.sender != _channel.sender && msg.sender != _channel.recipient) { throw; }
            address signer = ecrecover(h[1], v, h[2], h[3]);
            if (signer != _channel.sender) { throw; }
            
            bytes32 proof = sha3(h[0], value);
            if (proof != h[1]) { throw; }
            else if (value > _channel.deposit) { throw; }
            // Pay out recipient and refund sender the remainder
            if (!_channel.recipient.send(value)) { throw; }
            else if (!_channel.sender.send(_channel.deposit-value)) { throw; }
            
            // Memorize the recipient and channel id before closing the channel
            Channel_x = channels[id];
            Channel_x+=1;
            active_idx = active_ids[_channel.recipient];
            active_idx+=1;
            delete channels[h[0]];
            delete active_ids[_channel.sender][_channel.recipient];
        }
        
        function ChannelTimeout(bytes32 id){
            Channel memory _channel;
            _channel = channels[id];
            // Make sure it's not already closed and is actually expired
            if (_channel.deposit == 0) { throw; }
            else if (_channel.timeout > now) { throw; }
            else if (!_channel.sender.send(_channel.deposit)) { throw; }
            
            // Memorize the recipient and channel id before closing the channel
            Channel_x = channels[id];
            Channel_x+=1;
            active_idx = active_ids[_channel.recipient];
            active_idx+=1;
            delete channels[id];
            delete active_ids[_channel.sender][_channel.recipient];
        }
    }
}
