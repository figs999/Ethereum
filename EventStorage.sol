pragma solidity ^0.4.19;

contract EventStorage {

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This contract code has not been fully audited. DO NOT CONSIDER THIS PRODUCTION READY CODE!!!

This is a proof of concept for reduced gas cost verifiable data storage which uses event logs to store data on chain.
By having a client pass a block header along with the event payload into the ValidateEventStorage method, the contract
can decode and validate the block header, then search the block header's bloom filter for the event payload. This allows
the contract to verify the existence of the logged data.

In theory, this can allow for a significant reduction in gas cost when storing large byte arrays on chain while still
allowing a contract to work with the stored data. Via this method, it should be possible to store and validate the existence of
data blobs several kilobytes in size, far beyond what is possible with SSTORE due to block gas limits.

Below is comparative theoretical gas costs of various storage operations. "HashedEventStorage" refers to using the same method as
contained in this contract, but storing the hash of the logged data via SSTORE instead of relying on parsing the block header to
validate the passed in data blob.

Theoretical Gas Cost Breakdown (gas/byte [gas overhead]):
				New SSTORE 		| Existing SSTORE 	| EventStorage		| HashedEventStorage
Write 			625				| 156				| 8 [750]			| 8 [20750]
Read/Validate	-				| ~7				| 68* [~36k]		| 68* [200]
*cost is for each non-zero bytes, so for large data sets it will likely be slightly smaller due to the cheaper zero-bytes.

Cost of 1kB of storage:
				New SSTORE 		| Existing SSTORE 	| EventStorage		| HashedEventStorage
Write 			640k			| ~160k				| ~9k				| ~30k
Read/Validate	-				| 6400				| ~106k				| ~70k			

Cost of 10kB of storage:
				New SSTORE 		| Existing SSTORE 	| EventStorage		| HashedEventStorage
Write 			6.4M*			| -*				| ~83k				| ~103k
Read/Validate	-				| 64k*				| ~735k				| ~700k
*Technically, storage of this size would not be possible with SSTORE, due to block gas limits.

Check out Web3EncodeRLPHeader.js for a way to generate an RLP encoded header from client-side web3.
*/
    
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
    
    bytes32 constant eventTopic = keccak256(keccak256("DataStored(bytes,bytes)"));
    
    event DataStored(bytes indexed _data, bytes data);
    
    function StoreBytes(bytes data) public {
        DataStored(data, data);
    }
    
    function ValidateEventStorage(bytes rlpBlockHeader, bytes data) view public returns (bool valid){
        bytes memory logsBloom = parseBlockHeader(rlpBlockHeader).logsBloom;
        
        bytes32 _topic1 = keccak256(address(this));
        bytes32 _topic2 = eventTopic;
        bytes32 _topic3 = keccak256(keccak256(data));
        
        bool foundInLogs = true;
        
        for(uint b = 0; b < 8; b++) {
            bytes32 bloom = 0;
            for(uint i = 0; i < 6; i += 2) {
                assembly {
                    if eq(mod(byte(i, _topic1),8), b) {
                        bloom := or(bloom, exp(2,byte(add(1,i), _topic1)))
                    }
                    if eq(mod(byte(i, _topic2),8), b) {
                        bloom := or(bloom, exp(2,byte(add(1,i), _topic2)))
                    }
                    if eq(mod(byte(i, _topic3),8), b) {
                        bloom := or(bloom, exp(2,byte(add(1,i), _topic3)))
                    }
                }
            }
            
            assembly {
                if gt(bloom, 0) {
                    let bloomAnd := and(mload(add(logsBloom,mul(0x20,sub(8,b)))),bloom)
                    let equal := eq(bloomAnd,bloom)
                    
                    if eq(equal,0) {
                        b := 8
                        foundInLogs := 0
                    }
                }
            }
        }
        
        valid = foundInLogs;
    }
    
    function parseBlockHeader(bytes rlpData) internal view returns (BlockHeader) {
        BlockHeader memory parsedHeader;
        
        parsedHeader.derivedHash = keccak256(rlpData);
        bytes memory logsBloom = new bytes(256);
        
        assembly {
            calldatacopy(add(parsedHeader,32), 104, 32)                 //parentHash
            calldatacopy(add(parsedHeader,64), 137, 32)                 //ommersHash
            calldatacopy(add(parsedHeader,268), 170, 20)                //miner    
            calldatacopy(add(parsedHeader,96), 191, 32)                 //stateRoot
            calldatacopy(add(parsedHeader,128), 224, 32)                //transactionsRoot
            calldatacopy(add(parsedHeader,160), 257, 32)                //receiptsRoot
            
            calldatacopy(add(logsBloom,32), 292, 256)                   //logsBloom
            
            let _size := sub(and(calldataload(517), 0xFF), 128)
            calldatacopy(add(parsedHeader,sub(352,_size)), 549, _size)  //difficulty
            
            let _idx := add(add(549,_size),1)
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