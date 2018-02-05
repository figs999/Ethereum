pragma solidity ^0.4.18;

import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'http://github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';

/*
Author: Chance Santana-Wees
Contact Email: figs999@gmail.com

This contract code has not been fully audited. DO NOT CONSIDER THIS PRODUCTION READY CODE!!!

This token is a simple ERC20 token which has the added functionality 
of splitting all Ether payments made to it between it's current holders.

Any payment via the "payDividends" method is immediately split between token holders.

Payments made via a direct transfer can be split amongst token holders by a call to "sweepUnallocatedDividends".

This token stores a linked list of token holders in order to facilitate splitting dividend payments.
Each additional token hoder increases the gas cost of a dividend splitting transaction by 6010 gas.

In order to support an unlimited number of token holders:
    - A rolling version of the dividend splitting methods should be implemented.
    - Most functionality will need to be paused when a rolling split is started and unpaused upon completion.
*/

contract DividendToken is StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    struct Pointers {
        address next;
        address prev;
        uint dividends;
    }

    uint allocatedDividends = 0;
    uint paidDividends = 0;

    address head;
    mapping(address => Pointers) shareholders;

    function() public payable { }

    function addDividends(uint addedDividends) internal {
        uint pShare = addedDividends / totalSupply_;
        require(pShare > 0);

        allocatedDividends = SafeMath.add(allocatedDividends, addedDividends);
        
        address current = head;

        while (current > 0) {
            shareholders[current].dividends += pShare * balances[current];
            current = shareholders[current].next;
        }
    }

    function payDividends() public payable {
        addDividends(msg.value);
    }

    function sweepUnallocatedDividends() public {
        uint unallocatedDividends = this.balance - (allocatedDividends - paidDividends);
        addDividends(unallocatedDividends);
    }

    function transfer(address _to, uint256 _value) public returns (bool val) {
        require(_value > 0 && _to != 0);
        val = super.transfer(_to, _value);
        if(val)
            evaluateShareholders(_to, msg.sender);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool val) {
        require(_value > 0 && _to != 0);
        val = super.transferFrom(_from, _to, _value);
        if(val)
            evaluateShareholders(_to, _from);
    }

    function evaluateShareholders(address _to, address _from) internal {
        if (shareholders[_to].next == 0 && shareholders[_to].prev == 0 && _to != _from)
            insertShareholder(_to);

        if (balances[_from] == 0)
            removeShareholder(_from);
    }

    function insertShareholder(address shareHolder) internal {
        shareholders[head].prev = shareHolder;
        shareholders[shareHolder].next = head;
        head = shareHolder;
    }

    function removeShareholder(address shareHolder) internal {
        if(shareholders[shareHolder].dividends == 0)
        {
            address next = shareholders[shareHolder].next;
            address prev = shareholders[shareHolder].prev;
    
            if (next != 0)
                shareholders[next].prev = prev;
            if (prev != 0)
                shareholders[prev].next = next;
            else
                head = next;
                
            shareholders[shareHolder].next = 0;
            shareholders[shareHolder].prev = 0;
        }
    }
    
    function myDividendBalance() public view returns (uint dividends) {
        dividends = shareholders[msg.sender].dividends;
    }

    function withdrawDividends() public {
        address payee = msg.sender;
        uint payment = shareholders[payee].dividends;
        
        require(payment > 0);
        
        shareholders[msg.sender].dividends = 0;
        
        paidDividends = SafeMath.add(paidDividends,payment);

        if (balances[payee] == 0)
            removeShareholder(payee);

        payee.transfer(payment);
    }
}

contract TestDividendFund is DividendToken {
    string public name = "DividendFund";
    string public symbol = "DivFund";
    uint public decimals = 0;

    function TestDividendFund() public payable {
        totalSupply_ = 10000;
        
        balances[msg.sender] = totalSupply_;
        head = msg.sender;
    }
}