pragma solidity ^0.4.18;

import './zeppelin/token/ERC20/StandardToken.sol';
import './zeppelin/math/SafeMath.sol';
import './zeppelin/ownership/Ownable.sol';

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This contract code has not been fully audited. DO NOT CONSIDER THIS PRODUCTION READY CODE!!!

This token is an advanced dividend payment splitter which has the functionality of splitting
dividends made from any ERC20 compliant token to this contract amongst any number of holders.

The datastructures used for storing token holders and making claims to issued dividends allows
the gas cost of issuing dividends to be unbound by the number of token holders.

Cost of issuing and claiming dividends has O(n) relationship with number of tracked tokens.

This token should be accompanied by client side code which automates the process of determining
which blocks have dividends to be withdrawn by the user. This can be accomplished by determining
the clients historical balance by crawling the shareHoldersBalanceAtBlock structure and looking
for block numbers which were logged from SweepBalances().
*/

contract AdvancedDividendToken is StandardToken, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public minimumPayableShare;
    uint public heldPayableShares;
    
    struct BalanceAtBlock {
        uint32  block;
        uint224  balance;
    }
    
    mapping(address => BalanceAtBlock[]) public shareHoldersBalanceAtBlock;
    mapping(address => mapping(uint => uint)) public shareHolderTokenBalances;
    mapping(address => mapping(uint => bool)) public dividendsClaimedIntoBalance;
    
    mapping(uint => mapping(uint => uint)) public blockToTokenDividend;
    
    uint public latestDividendBlock = 0;
    
    ERC20[] public trackedTokens;
    uint[] public unclaimedDividends;

    function DividendToken() public {
        totalSupply_ = 1000000 ether;
        
        minimumPayableShare = 0.01 ether;
        heldPayableShares = totalSupply_ / minimumPayableShare;
        
        balances[msg.sender] = totalSupply_;
        handleBlockBalanceLedger(msg.sender, block.number-1, 0);
        
        TrackToken(ERC20(0)); //Not used, zero index represents Ether
    }

    function() public payable { }
    
    function TrackToken(ERC20 token) public {
        require(msg.sender == owner && trackedTokens.length < 0xFF);
        
        trackedTokens.push(token);
        unclaimedDividends.push(0x0);
    }
    
    event DividendIssued(uint block);
    
    function SweepBalances() public {
        bool hasLogged = false;
        
        uint etherDividend = this.balance.sub(unclaimedDividends[0]).div(heldPayableShares);
        if(etherDividend > 0)
        {
            blockToTokenDividend[block.number][0] = etherDividend;
            unclaimedDividends[0] = unclaimedDividends[0].add(etherDividend.mul(heldPayableShares));
            DividendIssued(block.number);
            latestDividendBlock = block.number;
            hasLogged = true;
        }
        
        address self = address(this);
        for(uint i = 1; i < trackedTokens.length; i++) {
            uint tokenDividend = trackedTokens[i].balanceOf(address(this)).sub(unclaimedDividends[i]).div(heldPayableShares);
            
            if(tokenDividend > 0) {
                blockToTokenDividend[block.number][i] = tokenDividend;
                unclaimedDividends[i] = unclaimedDividends[i].add(tokenDividend.mul(heldPayableShares));
                
                if(!hasLogged) {
                    DividendIssued(block.number);
                    latestDividendBlock = block.number;
                    hasLogged = true;
                }
            }
        }
    }

    function transfer(address _to, uint256 _value) public returns (bool val) {
        require(_value > 0 && _to != 0);
        
        uint fromBalance = balances[msg.sender];
        uint toBalance = balances[_to];
        
        val = super.transfer(_to, _value);
        
        if(val) {
            uint dividendBlock = latestDividendBlock;
            
            handleBlockBalanceLedger(_to, dividendBlock, toBalance);
            handleBlockBalanceLedger(msg.sender, dividendBlock, fromBalance);

            handlePayableSharesDelta(toBalance/minimumPayableShare + fromBalance/minimumPayableShare, balances[msg.sender]/minimumPayableShare + balances[_to]/minimumPayableShare);
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool val) {
        require(_value > 0 && _to != 0);
        
        uint fromBalance = balances[_from];
        uint toBalance = balances[_to];
        
        val = super.transferFrom(_from, _to, _value);
        
        if(val) {
            uint dividendBlock = latestDividendBlock;
            
            handleBlockBalanceLedger(_to, dividendBlock, toBalance);
            handleBlockBalanceLedger(_from, dividendBlock, fromBalance);

            handlePayableSharesDelta(toBalance/minimumPayableShare + fromBalance/minimumPayableShare, balances[_from]/minimumPayableShare + balances[_to]/minimumPayableShare);
        }
    }
    
    function handlePayableSharesDelta(uint beginPayableShares, uint endPayableShares) internal {
        if(endPayableShares != beginPayableShares) {
            uint allPayableShares = heldPayableShares;
            allPayableShares -= beginPayableShares;
            allPayableShares += endPayableShares;
            heldPayableShares = allPayableShares;
        }
    }

    function handleBlockBalanceLedger(address account, uint dividendBlock, uint oldBalance) internal {
        uint idx = shareHoldersBalanceAtBlock[account].length;

        if(idx == 0 || shareHoldersBalanceAtBlock[account][idx-1].block < dividendBlock) {
            shareHoldersBalanceAtBlock[account].push(BalanceAtBlock(uint32(block.number) - 1, uint224(oldBalance)));
        }
    }

    function claimDividendsForBlock(uint blockNumber) public {
        require(dividendsClaimedIntoBalance[msg.sender][blockNumber] == false);
        
        uint shares = balances[msg.sender];
        uint idx = shareHoldersBalanceAtBlock[msg.sender].length-1;
        uint32 sharesAtBlockNumber = shareHoldersBalanceAtBlock[msg.sender][idx].block;
        while(sharesAtBlockNumber >= blockNumber) {
            shares = uint(shareHoldersBalanceAtBlock[msg.sender][idx].balance);
            idx--;
            require(idx >= 0);
            sharesAtBlockNumber = shareHoldersBalanceAtBlock[msg.sender][idx].block;
        }
        
        shares = shares.div(minimumPayableShare);
        require(shares > 0);
        
        dividendsClaimedIntoBalance[msg.sender][blockNumber] = true;

        for(idx = 0; idx < trackedTokens.length; idx++) {
            uint myTokenDividend = blockToTokenDividend[blockNumber][idx].mul(shares);
            shareHolderTokenBalances[msg.sender][idx] = shareHolderTokenBalances[msg.sender][idx].add(myTokenDividend);
        }
    }
    
    function withdrawTokenBalance(uint tokenIndex) public {
        require(shareHolderTokenBalances[msg.sender][tokenIndex] > 0);
        
        uint tokenBalance = shareHolderTokenBalances[msg.sender][tokenIndex];
        shareHolderTokenBalances[msg.sender][tokenIndex] = 0;
        unclaimedDividends[tokenIndex] = unclaimedDividends[tokenIndex].sub(tokenBalance);
        
        if(tokenIndex > 0)
            require(trackedTokens[tokenIndex].transfer(msg.sender, tokenBalance));
        else
            msg.sender.transfer(tokenBalance);
    }
}