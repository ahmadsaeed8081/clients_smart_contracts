//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT_Minting is ERC721Enumerable, Ownable {
    using Strings for uint256;
   
    uint public Presale_Start_Time;
    uint public Presale_End_Time;
    string public baseURI; //private
    string public baseExtension = ".json";
    uint256 public cost = 0.8 ether;
    uint256 public presaleCost = 0.5 ether;
    uint256 public maxSupply = 5555;
    uint256 public maxMintAmount = 5;
    bool public paused = false;
    mapping(address => bool) public whitelisted;
   

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        uint _Presale_End_Time

    ) ERC721(_name, _symbol) {


        setBaseURI(_initBaseURI);
        mint(msg.sender, 20);
        Presale_End_Time= block.timestamp+(_Presale_End_Time * 1 days);
        Presale_Start_Time=block.timestamp;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable {

        uint256 supply = totalSupply();
        require(!paused,"minting is paused");
        require(_mintAmount > 0,"you didn't add any number");
        
        require(supply + _mintAmount <= maxSupply,"all Nfts has been sold");

        if (msg.sender != owner()) {
            require(_mintAmount <= maxMintAmount,"you cant mint more");
            if (whitelisted[msg.sender] != true) {
                if (block.timestamp<=Presale_End_Time) {
                    //preSale
                    require(msg.value >= presaleCost * _mintAmount,"hello6");
                } else {
                    //publicSale
                    require(msg.value >= cost * _mintAmount,"paying less than the public sale cost");
                    
                }
            }
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

       function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
            require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function Increase_Presale_Time(uint _days) public onlyOwner {

        if (block.timestamp<=Presale_End_Time)
        {
            Presale_End_Time=Presale_End_Time + (_days* 1 days);
        }
        else{
            Presale_End_Time=block.timestamp + (_days* 1 days);
        }

    }

    function End_preSale() external onlyOwner{

        require(block.timestamp>Presale_End_Time,"presale is already ended");
        Presale_End_Time=block.timestamp ;

    }

    function totalearning() public view onlyOwner returns(uint)
    {
        return address(this).balance;
    }

     function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
     
    // function withdraw() public onlyOwner {
    //     uint value=address(this).balance/4;
    //     owner1.transfer(value);
    //     owner2.transfer(value);
    //     owner3.transfer(value);
    //     owner4.transfer(value);
    // }
    // function getoldToken_URI(address _cont) public returns(string memory) {
    //     return Tokend(_cont).tokenURI(5);
    // }
    function curr_time() public view returns(uint) {
        return block.timestamp;
    }
    function AirDrop(address[] calldata _to,uint256[] calldata _id) external onlyOwner{
        require(_to.length == _id.length,"receivers and ids have different lengths");
        for(uint i=0;i<_to.length;i++)
        {
            safeTransferFrom(msg.sender,_to[i],_id[i]);
        }
    }

    function totalOwned_NFTs() external view returns(uint[] memory a){
       uint supply=totalSupply();
       require(supply>0);
       uint ids;
        for(uint i=1;i<=supply;i++)
        {
            if(ownerOf(i)==msg.sender)
            {
                ids++;
            }
        }
        
      
        if(ids==0)
        {
             uint[] memory All_Ids=new uint[](ids);
            All_Ids[0]=0;
            return All_Ids;
           
        }
        else if(ids>0){
             
            uint[] memory All_Ids=new uint[](ids);
            uint count;
            for(uint i=1;i<=supply;i++ )
            {
                if(ownerOf(i)==msg.sender)
                {
                    
                    All_Ids[count]=i;
                    count++;

                }
            }
           
           return All_Ids;
        }
        
    }
 

}