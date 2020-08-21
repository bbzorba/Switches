pragma solidity >=0.4.22 <0.8.0;
import "./PaymentChannel.sol";

contract Switches {
    
	address public addressA=0x1234;
	address public addressB=0x2345;
	address public addressC=0x3457;
    uint channel;
    uint rankA;
    uint rankB;
    uint rankC;
    PaymentChannel pc;
    
    function Switches(address addr, uint32 channel) public returns (uint wallet) {
    assembly {
        switch addr()
            case 0x1234 {
                switch channel 
                    case 5 {
                        pc.SimplePaymentChannel(0x1234, 100);
                        pc.isValidSignature(0x1234, 0x2345);
                        pc.close();
                        rankA=rankA+1;
                        break;
                    }
                    
                    case 10 {
                       
                        rankA++;
                        break;
                    }
                    
                    default {
                        ChannelTimeout(100);
                    }
                    
            }
            case addressB {
                switch channel 
                    case 5 {
                        
                        rankB++;
                        break;
                    }
                    
                    case 3 {
                        
                        rankB++;
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