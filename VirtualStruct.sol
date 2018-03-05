pragma solidity ^0.4.19;

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This sample outlines a technique for creating a stack-only "Virtual Struct" which fits in a single 256bit EVM word.

There are two primary benefits to using this technique rather than using a solidity struct:
    1) Stack only! (saves gas) The virtual structs never go into memory or storage unless explicitly 
        told to do so. I'm not a big fan of how liberaly the solidity compiler uses memory, and swapping 
        things in and out of memory when it isn't needed is an avoidable gas drain.
    2) More flexibility when compacting data. You are not bound to solidity's built-in data types and 
        can jam as much as possible into a single stack slot. Want to use 91 bits for something? Go ahead.

Comparitive Gas Costs of Below Contract Methods:
    Method                  Virtual Struct Cost             Normal Struct Cost
    PlaceADiceBet           43788                           70278 
    LogBetProperties        11040                           12281 

Notes:
    It was my first instinct to implement the code for handling the structure in a library, since that 
    would allow us to use "using X for Y" syntax to get the methods bound to our underlying data type.
    
    Unfortunately, this would mean that all of the calls to our structure's getters and setters would get
    handled by delegate calls, and the parameters for those calls would get put into memory... eliminating
    the first benefit listed above.
*/


//A Sample "Virtual Struct"
contract UsesBetRecord {
    enum GameType { DrawPoker, SimpleDice, BlackJack, Keno }
    
    /**--Virtual Structure-----------
     * BetRecord
     * Type        Name            Index   Bits
        uint16      PlayerID;       0       16      //Index of Player address in an array with max capacity of 65,535
        uint26      RevealBlock;    16      26      //This contract will fail in ~30 years... eh. 
        
        GameType    Type;           42      2       //Yes. 2. There is no reason that enum should take 256 bits!!!
        bytes15     WagerData;      44      120     //Biggest game is Keno, needs 6 bits per choice.
        
        bool        DidPayOut;      164     1       //Has the player already been paid?            
        
        uint...     WageredWei;     165     91      //left over bits can hold wager of up to ~2.5 billion ether. Should be plenty.
     **-------------------------------*/
    
    /**Here we create bit masks for all of our funky data sizes*/
    uint private constant mask1         = 1;                //binary 1
    uint private constant mask2         = (1 << 2)  -1;     //binary 11
    uint private constant mask16        = (1 << 16) -1;     //binary 1111 1111 1111 1111
    uint private constant mask26        = (1 << 26) -1;     //etc...
    uint private constant mask91        = (1 << 91) -1;    
    uint private constant mask120       = (1 << 120)-1;
    
    /**Here we create shift indices for each property. It is simply 1 shifted left by the Index listed above.*/
    uint private constant _PlayerID     = 1 << 0;
    uint private constant _RevealBlock  = 1 << 16;
    uint private constant _Type         = 1 << 42;
    uint private constant _WagerData    = 1 << 44;
    uint private constant _DidPayOut    = 1 << 164;
    uint private constant _WageredWei   = 1 << 165;
    
    /**Generic Getter/Setter which does the bit magic.*/
    function GetProperty(bytes32 BetRecord, uint mask, uint shift) private pure returns (uint property) {
        property = mask&(uint(BetRecord)/shift);
    }
    
    function SetProperty(bytes32 BetRecord, uint mask, uint shift, uint value) private pure returns (bytes32 updated) {
        updated = bytes32((~(mask*shift) & uint(BetRecord)) | ((value & mask) * shift));
    }
    
    /**--Getter Pattern--------------
    function <Property>     (bytes32 BetRecord)                 internal pure returns (<Type>)  { return   <Type>(  GetProperty( BetRecord, <Mask>, <Shift>));  }
     * 
     **--Setter Pattern--------------
    function <Property>     (bytes32 BetRecord, <Type> value)   internal pure returns (bytes32) { return            SetProperty( BetRecord, <Mask>, <Shift>,        uint(value) ); }
     */
    
    function GetPlayerID    (bytes32 BetRecord)                 internal pure returns (uint16)  { return   uint16(  GetProperty( BetRecord, mask16, _PlayerID));    }
    function SetPlayerID    (bytes32 BetRecord, uint16 value)   internal pure returns (bytes32) { return            SetProperty( BetRecord, mask16, _PlayerID,      value       ); }
    
    function GetRevealBlock (bytes32 BetRecord)                 internal pure returns (uint32)  { return   uint32(  GetProperty( BetRecord, mask26, _RevealBlock)); }
    function SetRevealBlock (bytes32 BetRecord, uint32 value)   internal pure returns (bytes32) { return            SetProperty( BetRecord, mask26, _RevealBlock,   value       ); }
    
    function GetType        (bytes32 BetRecord)                 internal pure returns (GameType){ return GameType(  GetProperty( BetRecord, mask2,  _Type));        }
    function SetType        (bytes32 BetRecord, GameType value) internal pure returns (bytes32) { return            SetProperty( BetRecord, mask2,  _Type,          uint(value) ); }
    
    function GetWagerData   (bytes32 BetRecord)                 internal pure returns (bytes15) { return  bytes15(  GetProperty( BetRecord, mask120,_WagerData));   }
    function SetWagerData   (bytes32 BetRecord, bytes15 value)  internal pure returns (bytes32) { return            SetProperty( BetRecord, mask120,_WagerData,     uint(value) ); }
    
    function GetDidPayOut   (bytes32 BetRecord)                 internal pure returns (bool)    { return       0 <  GetProperty( BetRecord, mask1,  _DidPayOut);    }
    function SetDidPayOut   (bytes32 BetRecord, bool value)     internal pure returns (bytes32) { return            SetProperty( BetRecord, mask1,  _DidPayOut,     value?1:0   ); }
    
    function GetWageredWei  (bytes32 BetRecord)                 internal pure returns (uint)    { return            GetProperty( BetRecord, mask91, _WageredWei);   }
    function SetWageredWei  (bytes32 BetRecord, uint value)     internal pure returns (bytes32) { return            SetProperty( BetRecord, mask91, _WageredWei,    value       ); }
}

contract UsingAVirtualStruct is UsesBetRecord{
    bytes32[] BetRecords;
    mapping(address => uint16) player2ID;
    address[] registeredPlayers;
    
    function UsingAVirtualStruct() public {
        registeredPlayers.push(0x0);
    }
    
    event PlayerRegistered(uint16 playerID, address player);
    event BetPlaced(bytes32 BetRecord, uint BetRecordID);
    
    function Register() public returns (uint16) {
        uint16 playerID = player2ID[msg.sender];
        require(playerID == 0 && registeredPlayers.length < 65535);

        playerID = uint16(registeredPlayers.length);
        registeredPlayers.push(msg.sender);
        player2ID[msg.sender] = playerID;
        PlayerRegistered(playerID, msg.sender);
        
        return playerID;
    }
    
    function PlaceADiceBet(uint8 number) public payable {
        uint16 playerID = player2ID[msg.sender];
        require(playerID > 0);
        
        bytes32 BetRecord;
        BetRecord = SetPlayerID(BetRecord, playerID);
        BetRecord = SetRevealBlock(BetRecord, uint32(block.number+10));
        BetRecord = SetType(BetRecord, GameType.SimpleDice);
        BetRecord = SetWagerData(BetRecord, bytes15(number));
        BetRecord = SetWageredWei(BetRecord, msg.value);
        
        uint betID = BetRecords.length;
        BetRecords.push(BetRecord);
        BetPlaced(BetRecord, betID);
    }
    
    event LogProperty(string name, uint value); 
    function LogBetProperties(uint betID) public {
        bytes32 BetRecord = BetRecords[betID];
        
        uint pID = GetPlayerID(BetRecord);
        uint RevealBlock = GetRevealBlock(BetRecord);
        GameType gameType = GetType(BetRecord);
        bytes15 wagerData = GetWagerData(BetRecord);
        uint wager = GetWageredWei(BetRecord);
        
        LogProperty("PlayerID", pID);
        LogProperty("RevealBlock", RevealBlock);
        LogProperty("Type", uint(gameType));
        LogProperty("WagerData", uint(wagerData));
        LogProperty("WageredWei", wager);
    }
}

contract UsingANormalStruct {
    enum GameType { DrawPoker, SimpleDice, BlackJack, Keno }
    
    struct BetRecord {
        uint16      PlayerID;       //16
        uint32      RevealBlock;    //48    Our first overhead. We're forced into 32 bits unless we want the contract to fail in 7.5 years.
        uint8       Type;           //56    Another overhead! We have to use 8 bits to hold a number that's 1-4! Still better than 256-bits for using the enum by typename.
        bytes15     WagerData;      //176   Luckily this is the same. Unfortunately it has a hard minimum, so we can't shave anything off of it to get back some lost bits.
        bool        DidPayOut;      //177
        uint72      WageredWei;     //249   Heres where we really got hammered. We have 79 bits available. Now we can only accept bets up to 4722 Ether! Goodbye highrollers! :P
    }
    
    BetRecord[] BetRecords;
    mapping(address => uint16) player2ID;
    address[] registeredPlayers;
    
    function UsingANormalStruct() public {
        registeredPlayers.push(0x0);
    }
    
    event PlayerRegistered(uint16 playerID, address player);
    event BetPlaced(BetRecord betRecord, uint BetRecordID);
    
    function Register() public returns (uint16) {
        uint16 playerID = player2ID[msg.sender];
        require(playerID == 0 && registeredPlayers.length < 65535);

        playerID = uint16(registeredPlayers.length);
        registeredPlayers.push(msg.sender);
        player2ID[msg.sender] = playerID;
        PlayerRegistered(playerID, msg.sender);
        
        return playerID;
    }
    
    function PlaceADiceBet(uint8 number) public payable {
        uint16 playerID = player2ID[msg.sender];
        require(playerID > 0 && msg.value < 1 << 72);
        
        BetRecord memory bet; //Immediately throwing this into memory. Better than accidentally putting it into storage though.
        bet.PlayerID = playerID;
        bet.RevealBlock = uint32(block.number+10);
        bet.Type = uint8(GameType.SimpleDice);
        bet.WagerData = bytes15(number);
        bet.WageredWei = uint72(msg.value);
        
        uint betID = BetRecords.length;
        BetRecords.push(bet);
        BetPlaced(bet, betID);
    }
    
    event LogProperty(string name, uint value); 
    function LogBetProperties(uint betID) public {
        BetRecord memory bet = BetRecords[betID];
        
        uint pID = bet.PlayerID;
        uint RevealBlock = bet.RevealBlock;
        GameType gameType = GameType(uint8(bet.Type));
        bytes15 wagerData = bet.WagerData;
        uint wager = bet.WageredWei;
        
        LogProperty("PlayerID", pID);
        LogProperty("RevealBlock", RevealBlock);
        LogProperty("Type", uint(gameType));
        LogProperty("WagerData", uint(wagerData));
        LogProperty("WageredWei", wager);
    }
}