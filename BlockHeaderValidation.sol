pragma solidity ^0.4.18;

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This contract code has not been fully audited. DO NOT CONSIDER THIS PRODUCTION READY CODE!!!

Have you ever wanted to figure out who mined a past block? 
It's timestamp? 
Maybe verify that a transaction receipt exists?
Now you can! And at only 4430 execution gas, it's a steal.

NOTE: You cannot currently use this as a library as you would expect, my usage of "calldatacopy" 
in assembly requires the transaction data to be in a very precise format. I'm working on conversion now.

Check out Web3EncodeRLPHeader.js for a way to generate an RLP encoded header from client-side web3.
*/

contract IngestBlockHeader {
    
    struct BlockHeader {
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
                                    
        bytes logsBloom;
    }
    
    function parseBlockHeader(bytes rlpData) public returns (BlockHeader) {
        BlockHeader memory parsedHeader;
        
        parsedHeader.derivedHash = keccak256(rlpData);
        bytes memory logsBloom = new bytes(256);
        
        assembly {
            calldatacopy(add(parsedHeader,32), 72, 32)                  //parentHash
            calldatacopy(add(parsedHeader,64), 105, 32)                 //ommersHash
            calldatacopy(add(parsedHeader,268), 138, 20)                //miner    
            calldatacopy(add(parsedHeader,96), 159, 32)                 //stateRoot
            calldatacopy(add(parsedHeader,128), 192, 32)                //transactionsRoot
            calldatacopy(add(parsedHeader,160), 225, 32)                //receiptsRoot
            
            calldatacopy(add(logsBloom,32), 260, 256)                   //logsBloom
            
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
        
        parsedHeader.logsBloom = logsBloom;
        
        require(parsedHeader.derivedHash == block.blockhash(parsedHeader.blockNumber));
        
        return parsedHeader;
    }
}