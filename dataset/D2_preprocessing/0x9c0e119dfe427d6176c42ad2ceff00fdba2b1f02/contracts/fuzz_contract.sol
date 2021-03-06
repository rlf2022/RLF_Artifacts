/**

 *Submitted for verification at Etherscan.io on 2019-04-29

*/



pragma solidity ^0.4.25 ;



contract TestABI{

    address owner;

    constructor() public payable{

        owner = msg.sender;

    }

    modifier onlyOwner(){

        require (msg.sender==owner);

        _;

    }

    function () payable public {

        // 其他逻辑

    }

    // 获取合约账户余额

    function getBalance() public constant returns(uint){

        return address(this).balance;

    }

    // 合约出账

    function sendTransfer(address _user,uint _price) public onlyOwner{

        require(_user!=owner);

        if(address(this).balance>=_price){

            _user.transfer(_price);

        }

    }

    // 提币

    function getEth(uint _price) public onlyOwner{

        if(_price>0){

            if(address(this).balance>=_price){

                owner.transfer(_price);

            }

        }else{

           owner.transfer(address(this).balance); 

        }

    }

}