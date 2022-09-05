//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Ticket{
   function whitelisted(address _this) external view returns(bool s);
}

contract NFT_Minting is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string private unRevealedURL="ipfs://ghjkgdgfhjbghttyuyutuuy/";
    bool public isRevealed=false; //private

    
    uint public Presale_Start_Time;
    uint public Presale_End_Time;
    string public baseURI; //private
    string public baseExtension = ".json";
    uint256 public cost = 0.2 ether;
    uint256 public presaleCost = 0.1 ether;
    uint256 public maxSupply = 5555;
    uint256 public maxMintAmount = 5;
    address  ticket_con;
    bool public paused = false;
     address[] public allWhitelisters;
    // mapping(address => bool) public whitelisted;


    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        uint _Presale_End_Time,
        address _Ticket_Contract

    ) ERC721(_name, _symbol) {


        setBaseURI(_initBaseURI);
       // mint(msg.sender, 20);
        Presale_End_Time= block.timestamp+(_Presale_End_Time * 1 days);
        Presale_Start_Time=block.timestamp;
        ticket_con=_Ticket_Contract;
    //    address[]  memory ticket_Whitlister  = Ticket(Ticket_Contract).ListOf_Allwhitelisters();
    //     Add_whitelistUser(ticket_Whitlister);
    
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
        require(_mintAmount <= maxMintAmount,"you cant mint more");
        require(supply + _mintAmount <= maxSupply,"all Nfts has been sold");

        if (msg.sender != owner()) 
        {
            if (block.timestamp<=Presale_End_Time) 
            {

                require (Ticket(ticket_con).whitelisted(msg.sender),"You are not whitelisted") ; 
                //preSale
                require(msg.value >= presaleCost * _mintAmount,"presaleCost is less");
                
            }
            else 
            {
                //publicSale
                require(msg.value >= cost * _mintAmount,"paying less than the public sale cost");
                
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
        if(isRevealed==true)
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
        else{
            return unRevealedURL;
        }

    }

    function reveal_collection()public onlyOwner{
        require(isRevealed!=true,"Collection is already revealed");
        isRevealed = true;
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

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    

    function Increase_Presale_days(uint _days) public onlyOwner {

        if (block.timestamp<=Presale_End_Time)
        {
            Presale_End_Time=Presale_End_Time + (_days* 1 days);
        }
        else{
            Presale_End_Time=block.timestamp + (_days* 1 days);
        }

    }

    function Increase_Presale_minutes(uint _mins) public onlyOwner {

        if (block.timestamp<=Presale_End_Time)
        {
            Presale_End_Time=Presale_End_Time + (_mins * 1 minutes);
        }
        else{
            Presale_End_Time=block.timestamp + (_mins* 1 minutes);
        }

    }

    function decrease_Presale_days(uint _days) public onlyOwner {

        require(block.timestamp<=Presale_End_Time,"Presale is already ended");
        
        Presale_End_Time=Presale_End_Time - (_days * 1 days);

    }

    function decrease_Presale_minutes(uint _mins) public onlyOwner {

        require(block.timestamp<=Presale_End_Time,"Presale is already ended");
        
        Presale_End_Time=Presale_End_Time - (_mins * 1 minutes);

    }

    function End_preSale() external onlyOwner
    {
        require(block.timestamp>Presale_End_Time,"presale is already ended");
        Presale_End_Time=block.timestamp;
    }

    function NFT_totalearning() public view onlyOwner returns(uint)
    {
        return address(this).balance;
    }

     function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
     
  
    function curr_time() public view returns(uint) {
        return block.timestamp;
    }

    function ListOf_All_SOLD_NFT() public view onlyOwner returns(address[] memory s  ) 
    {
        uint supply = totalSupply();
        address[] memory allOwners=new address[](supply);
        for(uint i=1;i<=supply;i++)
        {
            address temp= ownerOf(i);
             allOwners[i-1]=temp;
        }
       
        return allOwners;
        
    }
       function ListOf_Owners_AllNFTs() public view onlyOwner returns(uint[] memory s  ) 
    {
        uint supply = totalSupply();
        uint count;
        for(uint i=1;i<=supply;i++)
        {
            if(ownerOf(i)==msg.sender)
            {
                count++;
            }
            
           
        }
        uint[] memory all_Ids=new uint[](count);
          for(uint i=1;i<=supply;i++)
        {
            if(ownerOf(i)==msg.sender)
            {
                uint temp=i;
                all_Ids[i-1]=temp;
            }
            
           
        }
       
        return all_Ids;
        
    }
 

}