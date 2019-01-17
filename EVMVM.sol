/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This code is intended to allow a contract to execute arbitrary opcode input which has not been previously 
committed to the blockchain as a contract. Effectively, it is an VM of the EVM which is running on the EVM.
An EVM-VM, as it were.

I decided to attempt to optimize this functionality via usage of assembly so that I would not get the gas
overhead that would come from storing the virtual stack in memory. I also used a program counter trick to 
avoid having to do dozens of different jumpi (10 gas per!) operations, which should make the overall
execution overhead relatively low.

Notes:
    This is the first functional draft of the EVMVM. It actually works!
    
    For whatever reason I have to use an old compiler (0.4.6 seems to work) to get it to actually leave JUMPDESTs in.
    	Which means that there are a handful of EVM opcodes that aren't possible to use.

    If you don't want to handcode a bytecode function to run against this contract, a good way to test 
    	it is to run it in Remix (with compiler 0.4.6) and use the following input:
	["0x30","0x60","0x40","0x51","0x52","0x60","0x14","0x60","0x40","0x51","0x60","0x0c","0x01","0xa0"]
	This is a test function which loads ADDRESS, stores it to memory, and then does a log0 of it.
*/
pragma solidity ^0.4.0;
contract CodeRunner {
    function RunCode(bytes script) public {
        assembly{
			0x1f
			add //stack[0] becomes virtual program counter (vpc)
		_VM:											//program counter is 0xA0 here
			/*PUSH1*/ 			////The _VM subroutine reads a byte from 
			0x1 				////the input data, specified by the vpc,
			add //increment vpc		////and jumps to the correct subroutine
			dup1 				////based on mathematical offset.
			mload 				////The subroutines all perform the operation
			/*PUSH1*/ 			////specified and then jump back to _VM
			0x0
			byte
			/*PUSH1*/ 
			0x5 
			mul 
			/*PUSH1*/ 
			_OPS 
			add //acquire jump destination from opcode
			jump
		_OPS: 											//program counter is 0xB0 here
			//PUSH2
			//...
			STOP
			jump
		_0x01: 
			//PUSH2
			//...
			ADD
			jump
		_0x02: 
			//PUSH2
			//...
			MUL
			jump
		_0x03:  
			//PUSH2
			//...
			SUB
			jump
		_0x04:  
			//PUSH2
			//...
			DIV
			jump
		_0x05:  
			//PUSH2
			//...
			SDIV
			jump
		_0x06:  
			//PUSH2
			//...
			MOD
			jump
		_0x07:  
			//PUSH2
			//...
			SMOD
			jump
		_0x08:  
			//PUSH2
			//...
			ADDMOD
			jump
		_0x09:  
			//PUSH2
			//...
			MULMOD
			jump
		_0x0a:  
			//PUSH2
			//...
			EXP
			jump
		_0x0b:  
			//PUSH2
			//...
			SIGNEXTEND
			jump
		_0x0c:
			//PUSH2
			//...
			INVALID
			jump
		_0x0d:
			//PUSH2
			//...
			INVALID
			jump
		_0x0e:
			//PUSH2
			//...
			INVALID
			jump
		_0x0f:
			//PUSH2
			//...
			INVALID
			jump
		_0x10:  
			//PUSH2
			//...
			LT
			jump
		_0x11:  
			//PUSH2
			//...
			GT
			jump
		_0x12:  
			//PUSH2
			//...
			SLT
			jump
		_0x13:  
			//PUSH2
			//...
			SGT
			jump
		_0x14:  
			//PUSH2
			//...
			EQ
			jump
		_0x15:  
			//PUSH2
			//...
			ISZERO
			jump
		_0x16:  
			//PUSH2
			//...
			AND
			jump
		_0x17:  
			//PUSH2
			//...
			OR
			jump
		_0x18:  
			//PUSH2
			//...
			XOR
			jump
		_0x19:  
			//PUSH2
			//...
			NOT
			jump
		_0x1a:  
			//PUSH2
			//...
			BYTE
			jump
		_0x1b:
			//PUSH2
			//...
			INVALID
			jump
		_0x1c:
			//PUSH2
			//...
			INVALID
			jump
		_0x1d:
			//PUSH2
			//...
			INVALID
			jump
		_0x1e:
			//PUSH2
			//...
			INVALID
			jump
		_0x1f:
			//PUSH2
			//...
			INVALID
			jump
		_0x20:  
			//PUSH2
			//...
			SHA3
			jump
		_0x21:
			//PUSH2
			//...
			INVALID
			jump
		_0x22:
			//PUSH2
			//...
			INVALID
			jump
		_0x23:
			//PUSH2
			//...
			INVALID
			jump
		_0x24:
			//PUSH2
			//...
			INVALID
			jump
		_0x25:
			//PUSH2
			//...
			INVALID
			jump
		_0x26:
			//PUSH2
			//...
			INVALID
			jump
		_0x27:
			//PUSH2
			//...
			INVALID
			jump
		_0x28:
			//PUSH2
			//...
			INVALID
			jump
		_0x29:
			//PUSH2
			//...
			INVALID
			jump
		_0x2a:
			//PUSH2
			//...
			INVALID
			jump
		_0x2b:
			//PUSH2
			//...
			INVALID
			jump
		_0x2c:
			//PUSH2
			//...
			INVALID
			jump
		_0x2d:
			//PUSH2
			//...
			INVALID
			jump
		_0x2e:
			//PUSH2
			//...
			INVALID
			jump
		_0x2f:
			//PUSH2
			//...
			INVALID
			jump
		_0x30:  
			//PUSH2
			//...
			ADDRESS
			jump
		_0x31:  
			//PUSH2
			//...
			BALANCE
			jump
		_0x32:  
			//PUSH2
			//...
			ORIGIN
			jump
		_0x33:  
			//PUSH2
			//...
			CALLER
			jump
		_0x34:  
			//PUSH2
			//...
			CALLVALUE
			jump
		_0x35:  
			//PUSH2
			//...
			CALLDATALOAD
			jump
		_0x36:  
			//PUSH2
			//...
			CALLDATASIZE
			jump
		_0x37:  
			//PUSH2
			//...
			CALLDATACOPY
			jump
		_0x38:  
			//PUSH2
			//...
			CODESIZE
			jump
		_0x39:  
			//PUSH2
			//...
			CODECOPY
			jump
		_0x3a:  
			//PUSH2
			//...
			GASPRICE
			jump
		_0x3b:  
			//PUSH2
			//...
			EXTCODESIZE
			jump
		_0x3c:  
			//PUSH2
			//...
			EXTCODECOPY
			jump
		_0x3d:  
			//PUSH2
			//...
			RETURNDATASIZE
			jump
		_0x3e:  
			//PUSH2
			//...
			RETURNDATACOPY
			jump
		_0x3f:
			//PUSH2
			//...
			INVALID
			jump
		_0x40:  
			//PUSH2
			//...
			BLOCKHASH
			jump
		_0x41:  
			//PUSH2
			//...
			COINBASE
			jump
		_0x42:  
			//PUSH2
			//...
			TIMESTAMP
			jump
		_0x43:  
			//PUSH2
			//...
			NUMBER
			jump
		_0x44:  
			//PUSH2
			//...
			DIFFICULTY
			jump
		_0x45:  
			//PUSH2
			//...
			GASLIMIT
			jump
		_0x46:
			//PUSH2
			//...
			INVALID
			jump
		_0x47:
			//PUSH2
			//...
			INVALID
			jump
		_0x48:
			//PUSH2
			//...
			INVALID
			jump
		_0x49:
			//PUSH2
			//...
			INVALID
			jump
		_0x4a:
			//PUSH2
			//...
			INVALID
			jump
		_0x4b:
			//PUSH2
			//...
			INVALID
			jump
		_0x4c:
			//PUSH2
			//...
			INVALID
			jump
		_0x4d:
			//PUSH2
			//...
			INVALID
			jump
		_0x4e:
			//PUSH2
			//...
			INVALID
			jump
		_0x4f:
			//PUSH2
			//...
			INVALID
			jump
		_0x50:  
			//PUSH2
			//...
			POP
			jump
		_0x51:  
			//PUSH2
			//...
			MLOAD
			jump
		_0x52:  
			//PUSH2
			//...
			MSTORE
			jump
		_0x53:  
			//PUSH2
			//...
			MSTORE8
			jump
		_0x54:  
			//PUSH2
			//...
			SLOAD
			jump
		_0x55:  
			//PUSH2
			//...
			SSTORE
			jump
		_0x56:  
			//PUSH2
			//...
			JUMP
			jump
		_0x57:  
			//PUSH2
			//...
			JUMPI
			jump
		_0x58:  
			//PUSH2
			//...
			PC
			jump
		_0x59:  
			//PUSH2
			//...
			MSIZE
			jump
		_0x5a:  
			//PUSH2
			//...
			GAS
			jump
		_0x5b:  
			//PUSH2
			//...
			JUMPDEST
			jump
		_0x5c:
			//PUSH2
			//...
			INVALID
			jump
		_0x5d:
			//PUSH2
			//...
			INVALID
			jump
		_0x5e:
			//PUSH2
			//...
			INVALID
			jump
		_0x5f:
			//PUSH2
			//...
			INVALID
			jump
		_0x60:
			//PUSH2
			//...
			PUSH1
			jump
		_0x61:
			//PUSH2
			//...
			PUSH2
			jump
		_0x62:
			//PUSH2
			//...
			PUSH3
			jump
		_0x63:
			//PUSH2
			//...
			PUSH4
			jump
		_0x64: 
			//PUSH2
			//...
			PUSH5
			jump
		_0x65:  
			//PUSH2
			//...
			PUSH6
			jump
		_0x66:  
			//PUSH2
			//...
			PUSH7
			jump
		_0x67:  
			//PUSH2
			//...
			PUSH8
			jump
		_0x68:  
			//PUSH2
			//...
			PUSH9
			jump
		_0x69:  
			//PUSH2
			//...
			PUSH10
			jump
		_0x6a:  
			//PUSH2
			//...
			PUSH11
			jump
		_0x6b:  
			//PUSH2
			//...
			PUSH12
			jump
		_0x6c:  
			//PUSH2
			//...
			PUSH13
			jump
		_0x6d:  
			//PUSH2
			//...
			PUSH14
			jump
		_0x6e:  
			//PUSH2
			//...
			PUSH15
			jump
		_0x6f: 
			//PUSH2
			//...
			PUSH16
			jump
		_0x70:   
			//PUSH2
			//...
			PUSH17
			jump
		_0x71:   
			//PUSH2
			//...
			PUSH18
			jump
		_0x72:   
			//PUSH2
			//...
			PUSH19
			jump
		_0x73:   
			//PUSH2
			//...
			PUSH20
			jump
		_0x74:   
			//PUSH2
			//...
			PUSH21
			jump
		_0x75:   
			//PUSH2
			//...
			PUSH22
			jump
		_0x76:   
			//PUSH2
			//...
			PUSH23
			jump
		_0x77:   
			//PUSH2
			//...
			PUSH24
			jump
		_0x78:   
			//PUSH2
			//...
			PUSH25
			jump
		_0x79:   
			//PUSH2
			//...
			PUSH26
			jump
		_0x7a:   
			//PUSH2
			//...
			PUSH27
			jump
		_0x7b:   
			//PUSH2
			//...
			PUSH28
			jump
		_0x7c:   
			//PUSH2
			//...
			PUSH29
			jump
		_0x7d:   
			//PUSH2
			//...
			PUSH30
			jump
		_0x7e:   
			//PUSH2
			//...
			PUSH31
			jump
		_0x7f:   
			//PUSH2
			//...
			PUSH32
			jump
		_0x80:  
			//PUSH2
			//...
			DUP1
			jump
		_0x81:  
			//PUSH2
			//...
			DUP2
			jump
		_0x82:  
			//PUSH2
			//...
			DUP3
			jump
		_0x83:  
			//PUSH2
			//...
			DUP4
			jump
		_0x84:  
			//PUSH2
			//...
			DUP5
			jump
		_0x85:  
			//PUSH2
			//...
			DUP6
			jump
		_0x86:  
			//PUSH2
			//...
			DUP7
			jump
		_0x87:  
			//PUSH2
			//...
			DUP8
			jump
		_0x88:  
			//PUSH2
			//...
			DUP9
			jump
		_0x89:  
			//PUSH2
			//...
			DUP10
			jump
		_0x8a:  
			//PUSH2
			//...
			DUP11
			jump
		_0x8b:  
			//PUSH2
			//...
			DUP12
			jump
		_0x8c:  
			//PUSH2
			//...
			DUP13
			jump
		_0x8d:  
			//PUSH2
			//...
			DUP14
			jump
		_0x8e:  
			//PUSH2
			//...
			DUP15
			jump
		_0x8f:  
			//PUSH2
			//...
			DUP16   
			jump
		_0x90:  
			//PUSH2
			//...
			SWAP1
			jump
		_0x91:  
			//PUSH2
			//...
			SWAP2
			jump
		_0x92:  
			//PUSH2
			//...
			SWAP3
			jump
		_0x93:  
			//PUSH2
			//...
			SWAP4
			jump
		_0x94:  
			//PUSH2
			//...
			SWAP5
			jump
		_0x95:  
			//PUSH2
			//...
			SWAP6
			jump
		_0x96:  
			//PUSH2
			//...
			SWAP7
			jump
		_0x97:  
			//PUSH2
			//...
			SWAP8
			jump
		_0x98:  
			//PUSH2
			//...
			SWAP9
			jump
		_0x99:  
			//PUSH2
			//...
			SWAP10
			jump
		_0x9a:  
			//PUSH2
			//...
			SWAP11
			jump
		_0x9b:  
			//PUSH2
			//...
			SWAP12
			jump
		_0x9c:  
			//PUSH2
			//...
			SWAP13
			jump
		_0x9d:  
			//PUSH2
			//...
			SWAP14
			jump
		_0x9e:  
			//PUSH2
			//...
			SWAP15
			jump
		_0x9f:  
			//PUSH2
			//...
			SWAP16      
			jump
		_0xa0:  
			//PUSH2
			//...
			LOG0
			jump
		_0xa1:  
			//PUSH2
			//...
			LOG1
			jump
		_0xa2:  
			//PUSH2
			//...
			LOG2
			jump
		_0xa3:  
			//PUSH2
			//...
			LOG3
			jump
		_0xa4:  
			//PUSH2
			//...
			LOG4
			jump
		_0xa5:
			//PUSH2
			//...
			INVALID
			jump
		_0xa6:
			//PUSH2
			//...
			INVALID
			jump
		_0xa7:
			//PUSH2
			//...
			INVALID
			jump
		_0xa8:
			//PUSH2
			//...
			INVALID
			jump
		_0xa9:
			//PUSH2
			//...
			INVALID
			jump
		_0xaa:
			//PUSH2
			//...
			INVALID
			jump
		_0xab:
			//PUSH2
			//...
			INVALID
			jump
		_0xac:
			//PUSH2
			//...
			INVALID
			jump
		_0xad:
			//PUSH2
			//...
			INVALID
			jump
		_0xae:
			//PUSH2
			//...
			INVALID
			jump
		_0xaf:
			//PUSH2
			//...
			INVALID
			jump
		_0xb0:
			//PUSH2
			//...
			INVALID
			jump
		_0xb1:
			//PUSH2
			//...
			INVALID
			jump
		_0xb2:
			//PUSH2
			//...
			INVALID
			jump
		_0xb3:
			//PUSH2
			//...
			INVALID
			jump
		_0xb4:
			//PUSH2
			//...
			INVALID
			jump
		_0xb5:
			//PUSH2
			//...
			INVALID
			jump
		_0xb6:
			//PUSH2
			//...
			INVALID
			jump
		_0xb7:
			//PUSH2
			//...
			INVALID
			jump
		_0xb8:
			//PUSH2
			//...
			INVALID
			jump
		_0xb9:
			//PUSH2
			//...
			INVALID
			jump
		_0xba:
			//PUSH2
			//...
			INVALID
			jump
		_0xbb:
			//PUSH2
			//...
			INVALID
			jump
		_0xbc:
			//PUSH2
			//...
			INVALID
			jump
		_0xbd:
			//PUSH2
			//...
			INVALID
			jump
		_0xbe:
			//PUSH2
			//...
			INVALID
			jump
		_0xbf:
			//PUSH2
			//...
			INVALID
			jump
		_0xc0:
			//PUSH2
			//...
			INVALID
			jump
		_0xc1:
			//PUSH2
			//...
			INVALID
			jump
		_0xc2:
			//PUSH2
			//...
			INVALID
			jump
		_0xc3:
			//PUSH2
			//...
			INVALID
			jump
		_0xc4:
			//PUSH2
			//...
			INVALID
			jump
		_0xc5:
			//PUSH2
			//...
			INVALID
			jump
		_0xc6:
			//PUSH2
			//...
			INVALID
			jump
		_0xc7:
			//PUSH2
			//...
			INVALID
			jump
		_0xc8:
			//PUSH2
			//...
			INVALID
			jump
		_0xc9:
			//PUSH2
			//...
			INVALID
			jump
		_0xca:
			//PUSH2
			//...
			INVALID
			jump
		_0xcb:
			//PUSH2
			//...
			INVALID
			jump
		_0xcc:
			//PUSH2
			//...
			INVALID
			jump
		_0xcd:
			//PUSH2
			//...
			INVALID
			jump
		_0xce:
			//PUSH2
			//...
			INVALID
			jump
		_0xcf:
			//PUSH2
			//...
			INVALID
			jump
		_0xd0:
			//PUSH2
			//...
			INVALID
			jump
		_0xd1:
			//PUSH2
			//...
			INVALID
			jump
		_0xd2:
			//PUSH2
			//...
			INVALID
			jump
		_0xd3:
			//PUSH2
			//...
			INVALID
			jump
		_0xd4:
			//PUSH2
			//...
			INVALID
			jump
		_0xd5:
			//PUSH2
			//...
			INVALID
			jump
		_0xd6:
			//PUSH2
			//...
			INVALID
			jump
		_0xd7:
			//PUSH2
			//...
			INVALID
			jump
		_0xd8:
			//PUSH2
			//...
			INVALID
			jump
		_0xd9:
			//PUSH2
			//...
			INVALID
			jump
		_0xda:
			//PUSH2
			//...
			INVALID
			jump
		_0xdb:
			//PUSH2
			//...
			INVALID
			jump
		_0xdc:
			//PUSH2
			//...
			INVALID
			jump
		_0xdd:
			//PUSH2
			//...
			INVALID
			jump
		_0xde:
			//PUSH2
			//...
			INVALID
			jump
		_0xdf:
			//PUSH2
			//...
			INVALID
			jump
		_0xe0:
			//PUSH2
			//...
			INVALID
			jump
		_0xe1:
			//PUSH2
			//...
			INVALID
			jump
		_0xe2:
			//PUSH2
			//...
			INVALID
			jump
		_0xe3:
			//PUSH2
			//...
			INVALID
			jump
		_0xe4:
			//PUSH2
			//...
			INVALID
			jump
		_0xe5:
			//PUSH2
			//...
			INVALID
			jump
		_0xe6:
			//PUSH2
			//...
			INVALID
			jump
		_0xe7:
			//PUSH2
			//...
			INVALID
			jump
		_0xe8:
			//PUSH2
			//...
			INVALID
			jump
		_0xe9:
			//PUSH2
			//...
			INVALID
			jump
		_0xea:
			//PUSH2
			//...
			INVALID
			jump
		_0xeb:
			//PUSH2
			//...
			INVALID
			jump
		_0xec:
			//PUSH2
			//...
			INVALID
			jump
		_0xed:
			//PUSH2
			//...
			INVALID
			jump
		_0xee:
			//PUSH2
			//...
			INVALID
			jump
		_0xef:
			//PUSH2
			//...
			INVALID
			jump
		_0xf0:  
			//PUSH2
			//...
			CREATE
			jump
		_0xf1:  
			//PUSH2
			//...
			CALL
			jump
		_0xf2:  
			//PUSH2
			//...
			CALLCODE
			jump
		_0xf3:  
			//PUSH2
			//...
			RETURN
			jump
		_0xf4: 
			//PUSH2
			//...
			DELEGATECALL
			jump
		_0xf5:
			//PUSH2
			//...
			INVALID
			jump
		_0xf6:
			//PUSH2
			//...
			INVALID
			jump
		_0xf7:
			//PUSH2
			//...
			INVALID
			jump
		_0xf8:
			//PUSH2
			//...
			INVALID
			jump
		_0xf9:
			//PUSH2
			//...
			INVALID
			jump
		_0xfa: 
			//PUSH2
			//...
			STATICCALL
			jump
		_0xfb:
			//PUSH2
			//...
			INVALID
			jump
		_0xfc:
			//PUSH2
			//...
			INVALID
			jump
		_0xfd:  
			//PUSH2
			//...
			REVERT
			jump
		_0xfe:  
			//PUSH2
			//...
			INVALID
			jump
		_0xff: 
			//PUSH2
			//...
			SELFDESTRUCT
			jump
		STOP:				//program counter is 0x05B0 here
			stop	//the script's stop op will end execution of script here, no need to jump
		ADD:				//program counter is 0x05B2 here
			swap2
			swap1	//δ2 opcode, bury our vpc
			add
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry  
		MUL:				//program counter is 0x05BA here
			swap2
			swap1	//δ2 opcode, bury our vpc
			mul
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry          
		SUB:				//program counter is 0x05C2 here
			swap2
			swap1	//δ2 opcode, bury our vpc
			sub
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry  
		DIV:				//program counter is 0x05CA here
			swap2
			swap1	//δ2 opcode, bury our vpc
			div
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry           
		SDIV:				//program counter is 0x05D2 here
			swap2
			swap1	//δ2 opcode, bury our vpc
			sdiv
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry    
		MOD:				//program counter is 0x05DA here
			swap2
			swap1	//δ2 opcode, bury our vpc
			mod
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry            
		SMOD:				//program counter is 0x05E2 here
			swap2
			swap1	//δ2 opcode, bury our vpc
			mod
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry              
		ADDMOD:				//program counter is 0x05EA here
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			addmod
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry  
		MULMOD:				//program counter is 0x05F3 here
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			mulmod
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry       
		EXP:				//program counter is 0x05FC here
			swap2
			swap1	//δ2 opcode, bury our vpc
			exp
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SIGNEXTEND:			//program counter is 0x05FC here
			swap2
			swap1	//δ2 opcode, bury our vpc
			signextend
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		LT:					
			swap2
			swap1	//δ2 opcode, bury our vpc
			lt
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry        
		GT:					
			swap2
			swap1	//δ2 opcode, bury our vpc
			lt
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry           
		SLT:
			swap2
			swap1	//δ2 opcode, bury our vpc
			slt
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry    
		SGT:
			swap2
			swap1	//δ2 opcode, bury our vpc
			sgt
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry      
		EQ:
			swap2
			swap1	//δ2 opcode, bury our vpc
			eq
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry 
		ISZERO:
			swap1	//δ1 opcode, bury our vpc
			iszero
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		AND:
			swap2
			swap1	//δ2 opcode, bury our vpc
			and
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		OR:
			swap2
			swap1	//δ2 opcode, bury our vpc
			or
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		XOR:
			swap2
			swap1	//δ2 opcode, bury our vpc
			xor
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		NOT:
			swap1	//δ1 opcode, bury our vpc
			not
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		BYTE:
			swap2
			swap1	//δ2 opcode, bury our vpc
			byte
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SHA3:
			swap2
			swap1	//δ2 opcode, bury our vpc
			sha3
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		ADDRESS: 	//δ0 opcode, no need to bury our vpc	
			address
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		BALANCE:
			swap1	//δ1 opcode, bury our vpc
			balance
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		ORIGIN:		//δ0 opcode, no need to bury our vpc	
			origin
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLER:		//δ0 opcode, no need to bury our vpc	
			caller
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLVALUE:		//δ0 opcode, no need to bury our vpc	
			callvalue
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLDATALOAD:
			swap1	//δ1 opcode, bury our vpc
			calldataload
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLDATASIZE: 	//δ0 opcode, no need to bury our vpc	
			calldatasize
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLDATACOPY:
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			calldatacopy
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		CODESIZE:	//δ0 opcode, no need to bury our vpc	
			codesize
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CODECOPY:
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			codecopy
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		GASPRICE:	//δ0 opcode, no need to bury our vpc	
			gasprice
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		EXTCODESIZE: 	
			swap1	//δ1 opcode, bury our vpc
			extcodesize
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		EXTCODECOPY:
			swap4
			swap3
			swap2
			swap1	//δ4 opcode, bury our vpc
			extcodecopy
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		RETURNDATASIZE:	//δ0 opcode, no need to bury our vpc	
			INVALID	
			jump	//jump to _VM loop entry
		RETURNDATACOPY:
			INVALID
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		BLOCKHASH: 	
			swap1	//δ1 opcode, bury our vpc
			blockhash
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		COINBASE:	//δ0 opcode, no need to bury our vpc	
			coinbase
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		TIMESTAMP:	//δ0 opcode, no need to bury our vpc	
			timestamp
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		NUMBER:	//δ0 opcode, no need to bury our vpc	
			number
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		DIFFICULTY:	//δ0 opcode, no need to bury our vpc	
			difficulty
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		GASLIMIT:	//δ0 opcode, no need to bury our vpc	
			gaslimit
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		POP: 	
			swap1	//δ1 opcode, bury our vpc
			pop
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		MLOAD: 	
			swap1	//δ1 opcode, bury our vpc
			mload
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		MSTORE: 	
			swap2
			swap1	//δ2 opcode, bury our vpc
			mstore
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		MSTORE8: 	
			swap2
			swap1	//δ2 opcode, bury our vpc
			mstore8
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		SLOAD: 	
			swap1	//δ1 opcode, bury our vpc
			sload
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SSTORE: 	
			swap2
			swap1	//δ2 opcode, bury our vpc
			sstore
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		JUMP:
			pop		//α0 opcode, stack[1] becomes our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		JUMPI:		//program counter is 0x71D here
			swap2	//δ2 opcode, but with special action					stack[0] = vstack[1], stack[1] = vstack[0], stack[2] = vpc...
			not		//condition reversed
			//PUSH2	
			_nojump	//push destination for if we are NOT jumping			stack[0] = _dojump, stack[1] = vstack[1], stack[2] = vstack[0], stack[3] = vpc...
			jumpi	//jump if virtual JUMPI is NOT jumping					stack[0] = vstack[0], stack[1] = vpc...
			swap1	//if we ARE jumping, swap vpc back to top of stack		stack[0] = vpc, stack[1] = vstack[0]...
		_nojump:
			pop		//α0 opcode, stack[1] becomes our vpc. If we jumped to nojump, stack[1] was already our old vpc.
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		PC:
			dup1	//α0 opcode with special action, we simply duplicate the vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		MSIZE:	//δ0 opcode, no need to bury our vpc	
			msize
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		GAS:	//δ0 opcode, no need to bury our vpc	
			gas
			swap1	//α1 opcode, dig out our vpc
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		JUMPDEST:	//δ0 α0 opcode, effectively noop
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		PUSH1:
			//PUSH1
			0x1
			//PUSH2
			PUSH
			jump
		PUSH2:
			//PUSH1
			0x2
			//PUSH2
			PUSH
			jump
		PUSH3:
			//PUSH1
			0x3
			//PUSH2
			PUSH
			jump
		PUSH4:
			//PUSH1
			0x4
			//PUSH2
			PUSH
			jump
		PUSH5:
			//PUSH1
			0x5
			//PUSH2
			PUSH
			jump
		PUSH6:
			//PUSH1
			0x6
			//PUSH2
			PUSH
			jump
		PUSH7:
			//PUSH1
			0x7
			//PUSH2
			PUSH
			jump
		PUSH8:
			//PUSH1
			0x8
			//PUSH2
			PUSH
			jump
		PUSH9:
			//PUSH1
			0x9
			//PUSH2
			PUSH
			jump
		PUSH10:
			//PUSH1
			0xA
			//PUSH2
			PUSH
			jump
		PUSH11:
			//PUSH1
			0xB
			//PUSH2
			PUSH
			jump
		PUSH12:
			//PUSH1
			0xC
			//PUSH2
			PUSH
			jump
		PUSH13:
			//PUSH1
			0xD
			//PUSH2
			PUSH
			jump
		PUSH14:
			//PUSH1
			0xE
			//PUSH2
			PUSH
			jump
		PUSH15:
			//PUSH1
			0xF
			//PUSH2
			PUSH
			jump
		PUSH16:
			//PUSH1
			0x10
			//PUSH2
			PUSH
			jump
		PUSH17:
			//PUSH1
			0x11
			//PUSH2
			PUSH
			jump
		PUSH18:
			//PUSH1
			0x12
			//PUSH2
			PUSH
			jump
		PUSH19:
			//PUSH1
			0x13
			//PUSH2
			PUSH
			jump
		PUSH20:
			//PUSH1
			0x14
			//PUSH2
			PUSH
			jump
		PUSH21:
			//PUSH1
			0x15
			//PUSH2
			PUSH
			jump
		PUSH22:
			//PUSH1
			0x16
			//PUSH2
			PUSH
			jump
		PUSH23:
			//PUSH1
			0x17
			//PUSH2
			PUSH
			jump
		PUSH24:
			//PUSH1
			0x18
			//PUSH2
			PUSH
			jump
		PUSH25:
			//PUSH1
			0x19
			//PUSH2
			PUSH
			jump
		PUSH26:
			//PUSH1
			0x1A
			//PUSH2
			PUSH
			jump
		PUSH27:
			//PUSH1
			0x1B
			//PUSH2
			PUSH
			jump
		PUSH28:
			//PUSH1
			0x1C
			//PUSH2
			PUSH
			jump
		PUSH29:
			//PUSH1
			0x1D
			//PUSH2
			PUSH
			jump
		PUSH30:
			//PUSH1
			0x1E
			//PUSH2
			PUSH
			jump
		PUSH31:
			//PUSH1
			0x1F
			//PUSH2
			PUSH
			jump
		PUSH32:
			//PUSH1
			0x20
			//PUSH2
			PUSH
			jump
		PUSH:		//stack[0] contains quantity of bytes to push, stack[1] is vpc
			dup1 	//get second copy of quantity
			swap2	//move vpc to top of stack
			add		//increment vpc by offset
			dup1	//get second copy of vpc
			/*PUSH1*/
			0x1F
			swap1
			sub 	//stack[0] now is index to load push value
			mload	//stack[0] now is push value, with potential leading junk bytes
			swap1
			swap2	//rearrange stack, burying vpc, digging up number of loaded bytes
			dup1	//dup num bytes
			/*PUSH2*/
			0x100
			eq		//is num bytes 32?
			/*PUSH2*/
			_nomask
			jumpi
			/*PUSH2*/
			0x100
			exp
			/*PUSH1*/
			0x1
			swap1
			sub		//mask constructed for num bytes
			and		//apply mask
		_endmask:	//stack[0] now is push value (masked to relevant byte if needed)
			swap1	//α1 opcode, dig out our vpc (which has been offset already)
			//PUSH1 
			_VM	
			jump	//jump to _VM loop entry
		_nomask:
			pop
			/*PUSH2*/
			_endmask
			jump
		DUP1:
			dup2	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP2:
			dup3	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP3:
			dup4	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP4:
			dup5	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP5:
			dup6	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP6:
			dup7	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP7:
			dup8	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP8:
			dup9	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP9:
			dup10	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP10:
			dup11	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP11:
			dup12	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP12:
			dup13	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP13:
			dup14	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP14:
			dup15	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP15:
			dup16	//δ1 opcode, but with special action. No need to bury, we just dup 1 slot higher
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		DUP16:	
			//PUSH1 //δ1 opcode, but with special action. Need to store vpc to memory.
			0x40	//retrieve free memory pointer
			mstore	//save vpc to memory
			dup16
			//PUSH1
			0x40	//retrieve free memory pointer
			mload	//load vpc from memory
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP1:
			swap1	//δ1 opcode, bury our vpc
			swap2	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP2:
			swap1	//δ1 opcode, bury our vpc
			swap3	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP3:
			swap1	//δ1 opcode, bury our vpc
			swap4	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP4:
			swap1	//δ1 opcode, bury our vpc
			swap5	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP5:
			swap1	//δ1 opcode, bury our vpc
			swap6	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP6:
			swap1	//δ1 opcode, bury our vpc
			swap7	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP7:
			swap1	//δ1 opcode, bury our vpc
			swap8	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP8:
			swap1	//δ1 opcode, bury our vpc
			swap9	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP9:
			swap1	//δ1 opcode, bury our vpc
			swap10	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP10:
			swap1	//δ1 opcode, bury our vpc
			swap11	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP11:
			swap1	//δ1 opcode, bury our vpc
			swap12	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP12:
			swap1	//δ1 opcode, bury our vpc
			swap13	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP13:
			swap1	//δ1 opcode, bury our vpc
			swap14	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP14:
			swap1	//δ1 opcode, bury our vpc
			swap15	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP15:
			swap1	//δ1 opcode, bury our vpc
			swap16	//vpc is between vstack[0] and [1], so we do one greater swap than requested.  
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		SWAP16:	
			//PUSH1 //δ1 opcode, but with special action. Need to store vpc to memory.
			0x40	//retrieve free memory pointer
			mstore	//save vpc to memory
			swap16
			//PUSH1
			0x40	//retrieve free memory pointer
			mload	//load vpc from memory
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		LOG0:				
			swap2
			swap1	//δ2 opcode, bury our vpc
			log0
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		LOG1:				
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			log1
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		LOG2:				
			swap4
			swap3
			swap2
			swap1	//δ4 opcode, bury our vpc
			log2
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		LOG3:				//program counter is 0x05F3 here
			swap5
			swap4
			swap3
			swap2
			swap1	//δ5 opcode, bury our vpc
			log3
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		LOG4:				
			swap6
			swap5
			swap4
			swap3
			swap2
			swap1	//δ6 opcode, bury our vpc
			log4
			//PUSH1 //α0 opcode, no need to dig out our vpc
			_VM	
			jump	//jump to _VM loop entry
		CREATE:				//program counter is 0x05F3 here
			swap3
			swap2
			swap1	//δ3 opcode, bury our vpc
			create
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALL:				
			swap7
			swap6
			swap5
			swap4
			swap3
			swap2
			swap1	//δ7 opcode, bury our vpc
			call
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		CALLCODE:				
			swap7
			swap6
			swap5
			swap4
			swap3
			swap2
			swap1	//δ7 opcode, bury our vpc
			callcode
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		RETURN:				
			pop 	//δ2 opcode, but execution is halting, so just discard vpc
			return	
		DELEGATECALL:				
			swap6
			swap5
			swap4
			swap3
			swap2
			swap1	//δ6 opcode, bury our vpc
			delegatecall
			swap1	//α1 opcode, dig out our vpc
			//PUSH1
			_VM	
			jump	//jump to _VM loop entry
		STATICCALL:				
		    	INVALID
			jump	//jump to _VM loop entry
		REVERT:
			INVALID
			jump
		INVALID:
			stop	//should not be reachable... unless the program code is itself invalid
		SELFDESTRUCT:
			pop 	//δ1 opcode, but execution is halting, so just discard vpc
			selfdestruct
		}
    }
}
