//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract wallet {

    address public walletOwner;
    
    uint withdrawlAllowance;

    mapping(address => uint) accounts;      //Used in withdrawFunds function.
    mapping(address => uint) allowances;    //Used in setAnAllowance function.    

    constructor() {
        walletOwner = msg.sender;       //Set the wallet owner to who creates contract
    }

    function setAnAllowance(address payable _to, uint _allowance) public {
        require(_to == msg.sender, "You are not the account holder!");         //Only the account address can set their allowance limit.
        allowances[_to] = _allowance;
    }

    function withdrawFunds(address payable _to, uint _amount) public {
        require(walletOwner == msg.sender, "Withdrawls not allowed unless you are the wallet owner.");  //Check account owner.
        require(_amount <= accounts[msg.sender], "Insufficient funds!");                                     //Check for funds.

        if (allowances[msg.sender] > 0) {                                   //Check withdrawl allowance.
            require(_amount <= allowances[msg.sender], "You are exceeding the allowance amount, aborting!");     
        }

        accounts[msg.sender] -= _amount;     //Place here before send to prevent reentrancy hack

        bool sendStatus = payable(_to).send(_amount);
        require(sendStatus, "Error in sending funds!"); //Error trap if send doesn't work
    }

    function changeOwner(address _newOwner) public {
        require(walletOwner == msg.sender, "Must be wallet owner!");     

        walletOwner = _newOwner;       //Set new wallet owner.
    }

    receive() external payable {
        accounts[msg.sender] += msg.value;
    }

}