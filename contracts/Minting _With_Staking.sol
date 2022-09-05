//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface Reward_Token{
    function transfer(address to, uint256 amount) external returns (bool);

}
contract NFT_Minting is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string private unRevealedURL="ipfs://ghjkgdgfhjbghttyuyutuuy/";
    bool public isRevealed=false; //private
    

    struct NFT_Owners
    {      
       address[] NFT_owners;
       uint ID;
    }

    struct NFT_Data{

        mapping(uint=>uint) purchase_time;
        mapping(uint=>uint) sold_time;
        uint temp;

    }
    mapping(address=>uint) public withdrawn;
    mapping(uint => NFT_Owners ) public ownerList;
    mapping(uint=>mapping(address=>NFT_Data))public data;
    uint public no;
    address reward_token;
    uint reward_per_day=1;
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
        address _reward_token,
        uint _Presale_End_Time

    ) ERC721(_name, _symbol) {


        setBaseURI(_initBaseURI);
       mint(msg.sender, 1);
        Presale_End_Time= block.timestamp+(_Presale_End_Time * 1 days);
        Presale_Start_Time=block.timestamp;
        reward_token=_reward_token;

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

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
     
    function curr_time() public view returns(uint) {
        return block.timestamp;
    }

    function _mint(address to, uint256 tokenId) internal virtual override
    {
        
        ownerList[tokenId].ID=tokenId;
        data[tokenId][to].purchase_time[1]=block.timestamp;
        ownerList[tokenId].NFT_owners.push(to);
        super._mint(to,tokenId);  

    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override{
        super._transfer(from,to,tokenId);
        uint index=1;
        uint index1=0;
        uint total = ownerList[tokenId].NFT_owners.length;
        for(uint i=0;i<total;i++)
        {
            if(ownerList[tokenId].NFT_owners[i]==to)
            {
                index++;
            }
            if(ownerList[tokenId].NFT_owners[i]==from)
            {
                index1++;
            }
        }
        ownerList[tokenId].NFT_owners.push(to);
        data[tokenId][to].purchase_time[index]=block.timestamp;
        data[tokenId][from].sold_time[index1]=block.timestamp;
        
      

    }
    // function getownerList(uint token) public view returns(address[] memory){
       
    //     uint total = ownerList[token].NFT_owners.length;
    //     address[] memory arr=new address[](total);
    //     for(uint i=0;i<total;i++)
    //     {
    //         arr[i]=ownerList[token].NFT_owners[i];
    //     }
    //     return arr;

    // }

    function get_Reward() public view returns(uint){
        uint supply=totalSupply();
        uint count;
        uint Total_Time;
        for(uint i=1;i<=supply;i++)
        {
            uint total = ownerList[i].NFT_owners.length;
            count=0;
            for(uint j=0;j<total;j++)
            {
                if(ownerList[i].NFT_owners[j]==msg.sender)
                {
                    count++;
                }
            }
            for(uint k=1;k<=count;k++)
            {
                uint buying_time = data[i][msg.sender].purchase_time[k];
                uint sold_time = data[i][msg.sender].sold_time[k];
                if(sold_time > 0)
                {
                    Total_Time = Total_Time +(sold_time-buying_time);   
                }
                else if(sold_time==0)
                {
                    Total_Time = Total_Time + (block.timestamp-buying_time);
                }

                
            }
        }
        // uint Total_days=((Total_Time/60)/60)/24;
        uint Total_days=(Total_Time/60);
        if(Total_days>0)
        {
            return (Total_days * reward_per_day)-withdrawn[msg.sender];
        }
        return 0;

    }
    function getTime() public view returns(uint){
       return  data[2][msg.sender].purchase_time[1];
     
    }
    function claimReward() public {
        uint reward=get_Reward();
        require(reward>0,"you dont have rewards");
        // Reward_Token(reward_token).transfer(msg.sender,reward);
        withdrawn[msg.sender]+=reward;
    }



 

}