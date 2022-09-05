//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFT is ERC721URIStorage,Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 
    address contractAddress;
    mapping(string=>bool) public colors; 
    uint public mint_price=0.001 ether;
    string[] public All_minted_colors;
    mapping(address=>bool) public whitelisted;
    constructor() ERC721("jumpo", "jmp")
    {
        
    }

    function createToken(string memory tokenURI,string memory _color) payable external{
        require(mint_price==msg.value,"your price is less then then the mint amount");
        require(colors[_color]==false,"this color has already been used");
        All_minted_colors.push(_color);
        colors[_color]=true;
        _tokenIds.increment();
        uint256 newItemId =_tokenIds.current();
        _mint(msg.sender,newItemId);//mint the token
        _setTokenURI(newItemId,tokenURI);//generate the URI
        // setApprovalForAll(contractAddress,true);//grant transaction permission
    }

    function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{
        value: address(this).balance
    }("");
    require(success);
    }
    //set mint price function
    function set_Mint_price(uint256 _newCost) public onlyOwner{
        mint_price=_newCost;
    }
    // total earning function
    function totalearning() public view onlyOwner returns(uint)
    {
        return address(this).balance;
    }
    function listOfColors() public view returns(string[] memory){
       uint length = All_minted_colors.length;
       string[] memory arr=new string[](length);
       for(uint i=0;i<length;i++)
       {
           arr[i]=All_minted_colors[i];
       }
       return arr;
    }
        function addWhitelistUsers(address[] memory _users) public onlyOwner {
        uint total_users = _users.length;
        for (uint256 i = 0; i < total_users; i++) {
            whitelisted[_users[i]] = true;
        }
    }

    function removeWhitelistUsers(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }
    
    function AirDrop(address[] calldata _to,uint256[] calldata _id) external onlyOwner{
        require(_to.length == _id.length,"receivers and ids have different lengths");
        for(uint i=0;i<_to.length;i++)
        {
            safeTransferFrom(msg.sender,_to[i],_id[i]);
        }
    }




 
}