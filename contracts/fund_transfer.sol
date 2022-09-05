//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract NFT {

    address payable public owner;

    uint public gold = 0.65 ether;

    uint public Silver = 0.35 ether;

    uint public Diamond = 1.25 ether;

constructor(){
    owner= payable(msg.sender);
}


    function NFT_Funds(uint  nft) public payable returns(bool) 
    {

        if(nft==0)
        {
            require(msg.value==Silver);
            owner.transfer(msg.value);

        }
        else if(nft==1)
        {
            require(msg.value==gold);

            owner.transfer(msg.value);

        }
        else if(nft==2)
        {
            require(msg.value==Diamond);

            owner.transfer(msg.value);

        }
        return true;

    }


    function set_Silver(uint _silver) public{

        Silver = _silver;
    }

     function set_gold(uint _gold) public{

        gold = _gold;
    }

    function set_Diamond(uint _Diamond) public{

        Diamond = _Diamond;
    }


}