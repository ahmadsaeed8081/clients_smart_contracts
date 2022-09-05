//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT_Minting is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string private unRevealedURL="ipfs://ghjkgdgfhjbghttyuyutuuy/";
    bool public isRevealed=false; //private

    address payable  owner1;
    address payable  owner2;
    address payable  owner3;
    address payable  owner4;
    uint public Presale_Start_Time;
    uint public Presale_End_Time;
    string public baseURI; //private
    string public baseExtension = ".json";
    uint256 public cost = 0.12 ether;
    uint256 public presaleCost = 0.08 ether;
    uint256 public maxSupply = 5555;
    uint256 public maxMintAmount = 5;
    bool public paused = false;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public presaleWallets;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        address _owner1,
        address _owner2,
        address _owner3,
        address _owner4,
        uint _Presale_End_Time

    ) ERC721(_name, _symbol) {


        setBaseURI(_initBaseURI);
       // mint(msg.sender, 20);
        Presale_End_Time= block.timestamp+(_Presale_End_Time * 1 days);
        Presale_Start_Time=block.timestamp;
        owner1 =payable(_owner1);
        owner2 = payable(_owner2);
        owner3 = payable(_owner3);
        owner4 = payable(_owner4);
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

        if (msg.sender != owner()) {
            if (whitelisted[msg.sender] != true) {
                

                if (block.timestamp<=Presale_End_Time) {
                    //preSale
                    require(msg.value >= presaleCost * _mintAmount,"hello6");
                    for (uint256 i = 1; i <= _mintAmount; i++) {
                         _safeMint(_to, supply + i);
                    }
                } else {
                    //publicSale
                    require(msg.value >= cost * _mintAmount,"paying less than the public sale cost");
                    for (uint256 i = 1; i <= _mintAmount; i++) {
                        _safeMint(_to, supply + i);
                    }
                    
                }
            }
            else{

                if (block.timestamp<=Presale_End_Time) {
                    //preSale
                    require(msg.value >= presaleCost * (_mintAmount-1),"paying less than the PreSale cost");

                } else {
                    //publicSale
                    require(msg.value >= cost * (_mintAmount-1),"paying less than the public sale cost");
                    
                }
                whitelisted[msg.sender]=false;
                for (uint256 i = 1; i <= _mintAmount; i++) {
                _safeMint(_to, supply + i);
                }
            }
        }
        else
        {
            for (uint256 i = 1; i <= _mintAmount; i++) 
            {
                _safeMint(_to, supply + i);
            }
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
    function End_preSale() external onlyOwner
    {
        require(block.timestamp>Presale_End_Time,"presale is already ended");
        Presale_End_Time=block.timestamp ;
    }
    function totalearning() public view onlyOwner returns(uint)
    {
        return address(this).balance;
    }
    //  function withdraw() public payable onlyOwner {
    //     (bool success, ) = payable(msg.sender).call{
    //         value: address(this).balance
    //     }("");
    //     require(success);
    // }
     
    function withdraw() public onlyOwner {
        uint value60=(address(this).balance/100)*60;
        uint value25=(address(this).balance/100)*25;
        uint value10=(address(this).balance/100)*10;
        uint value5=(address(this).balance/100)*5;
        owner1.transfer(value60);
        owner2.transfer(value25);
        owner3.transfer(value10);
        owner4.transfer(value5);
    }
    // function getoldToken_URI(address _cont) public returns(string memory) {
    //     return Tokend(_cont).tokenURI(5);
    // }
    function curr_time() public view returns(uint) {
        return block.timestamp;
    }
 

}