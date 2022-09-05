//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import"./contractsCopy/token/ERC721/extensions/ERC721Enumerable.sol";
import"./contractsCopy/access/Ownable.sol";
// import "/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

contract TicketNFT is ERC721Enumerable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.3 ether;
    uint256 public maxSupply = 693;
    uint256 public maxMintAmount = 1;
    bool public paused = false;
    address[] public blacklisted;
    struct Ticket
    {

        address owner;
        address ID;
        uint Price;
        uint Time; 
    }

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        mint(msg.sender, 1);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable {

        uint256 supply = totalSupply();
        require(!paused,"minting is paused by the owner");
        
       // require(_mintAmount <= maxMintAmount,"you minting value is more than one");
        require(supply + _mintAmount <= maxSupply,"minting is over");

        if (msg.sender != owner())
        {
            require(_mintAmount == 1,"mint amount should be 1");
            require(balanceOf(_to)==0,"you can't buy more than one Ticket");
            require(msg.value >= cost * _mintAmount,"value is less");
 
        }
          
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }


    }

    function getwhitelisted(address _this) public view returns(bool s){
        return whitelisted[_this];
    }

    function Owners_Ticket(address _owner)
        public
        view
        onlyOwner
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

    function ListOf_AllTicketOwners() public view onlyOwner returns(address[] memory s  ) 
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

    function Ticket_totalearning() public view onlyOwner returns(uint)
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

}