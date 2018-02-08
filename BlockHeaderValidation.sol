pragma solidity ^0.4.18;

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This contract code has not been fully audited. DO NOT CONSIDER THIS PRODUCTION READY CODE!!!

Have you ever wanted to figure out who mined a past block? 
It's timestamp? 
Maybe verify that a transaction receipt exists?
Now you can! And at only 4430 execution gas, it's a steal.

If you want to have a user generate RLP encoded header arrays from javascript, use this:

		//Pass in a block produced from web3.eth.GetBlock
		var encode = function(block) {
			return  hexToBytes("f90205" + 
						encode_with_length(block.parentHash.slice(2)) +
						encode_with_length(block.sha3Uncles.slice(2)) +
						encode_with_length(block.miner.slice(2)) +
						encode_with_length(block.stateRoot.slice(2)) +
						encode_with_length(block.transactionsRoot.slice(2)) +
						encode_with_length(block.receiptsRoot.slice(2)) +
						"b90100" + block.logsBloom.slice(2) + 
						encode_with_length(block.difficulty.toString(16)) +
						encode_with_length(block.number.toString(16)) + 
						encode_with_length(block.gasLimit.toString(16)) + 
						encode_with_length(block.gasUsed.toString(16)) + 
						encode_with_length(block.timestamp.toString(16)) + 
						encode_with_length(block.extraData.slice(2)) +
						encode_with_length(block.mixHash.slice(2)) + 
						encode_with_length(block.nonce.slice(2)))
		}
		
		function hexToBytes(hex) {
			for (var bytes = [], c = 0; c < hex.length; c += 2)
			bytes.push(parseInt(hex.substr(c, 2), 16));
			return bytes;
		}

		var encode_with_length = function(input) {
			if(input.length % 2 != 0)
				input = "0" + input;
			return (input.length/2 + 128).toString(16) + input;
		}
*/

library BlockHeaderValidation {
    struct Header {
        bytes32 derivedHash;        
        bytes32 parentHash;         
        bytes32 ommersHash;         
        
        bytes32 stateRoot;          
        bytes32 transactionsRoot;   
        bytes32 receiptsRoot;         
        
        bytes32 mixHash;            
        bytes32 extraData;          
        
        address miner;              
        
        bytes8 nonce;               

        uint difficulty;            
        uint32 blockNumber;         
        uint32 gasLimit;            
        uint32 gasUsed;             
        uint32 timeStamp;           
                                    
        bytes32 logsBloom1;         
        bytes32 logsBloom2;         
        bytes32 logsBloom3;         
        bytes32 logsBloom4;         
        bytes32 logsBloom5;         
        bytes32 logsBloom6;         
        bytes32 logsBloom7;         
        bytes32 logsBloom8;            
    }
    
    function parseBlockHeader(bytes rlpData) public view returns (Header parsedHeader) {
        parsedHeader.derivedHash = keccak256(rlpData);
        
        assembly {
            calldatacopy(add(parsedHeader,32), 72, 32)                  //parentHash
            calldatacopy(add(parsedHeader,64), 105, 32)                 //ommersHash
            calldatacopy(add(parsedHeader,268), 138, 20)                //miner    
            calldatacopy(add(parsedHeader,96), 159, 32)                 //stateRoot
            calldatacopy(add(parsedHeader,128), 192, 32)                //transactionsRoot
            calldatacopy(add(parsedHeader,160), 225, 32)                //receiptsRoot
            calldatacopy(add(parsedHeader,480), 260, 256)               //logsBloom
            
            let _size := sub(and(calldataload(485), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(352,_size)), 517, _size)  //difficulty
            
            let _idx := add(add(517,_size),1)
            _size := sub(and(calldataload(sub(_idx,32)), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(384,_size)), _idx, _size) //blockNumber
            
            _idx := add(add(_idx,_size),1)
            _size := sub(and(calldataload(sub(_idx,32)), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(416,_size)), _idx, _size) //gasLimit
            
            _idx := add(add(_idx,_size),1)
            _size := sub(and(calldataload(sub(_idx,32)), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(448,_size)), _idx, _size) //gasUsed
            
            _idx := add(add(_idx,_size),1)
            _size := sub(and(calldataload(sub(_idx,32)), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(480,_size)), _idx, _size) //timeStamp
            
            _idx := add(add(_idx,_size),1)
            _size := sub(and(calldataload(sub(_idx,32)), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(256,_size)), _idx, _size) //extraData
            
            _idx := add(add(_idx,_size),1)
            calldatacopy(add(parsedHeader,192), _idx, 32)               //mixHash

            _idx := add(_idx,33)
            calldatacopy(add(parsedHeader,288), _idx, 8)                //nonce
        }
        
        
        assert(parsedHeader.derivedHash == block.blockhash(parsedHeader.blockNumber));
        
        return parsedHeader;
    }
}