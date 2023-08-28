//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MonkeyDoo is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 1 ether;
  uint256 public maxSupply = 3000;
  uint256 public maxMintAmount = 3000;
  bool public paused = false;
  bool public revealed = true;
  string public notRevealedUri;
  uint256[] public minted;
  uint256 public totalMinted = 0;

  

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }


  function mint(uint256 [] memory _mints) public payable {
    uint256 supply = totalMinted;
    require(!paused);
    uint256[] memory arrFunds = _mints;
    require(arrFunds.length > 0);
    require(arrFunds.length <= maxMintAmount);
    require(supply + arrFunds.length <= maxSupply);

     if (msg.sender != owner()) {
      require(msg.value >= cost * arrFunds.length);
    }

    for(uint256 i = 0; i < arrFunds.length; i++)
    {
      
      _safeMint(msg.sender, arrFunds[i]);
      minted.push(arrFunds[i]);
      totalMinted++;
    }
    
   
  }

  function baje(address receiver, uint256 [] memory _mints) public {
    uint256 supply = totalMinted;
    require(!paused);
    uint256[] memory arrFunds = _mints;
    require(arrFunds.length > 0);
    require(arrFunds.length <= maxMintAmount);
    require(supply + arrFunds.length <= maxSupply);


    for(uint256 i = 0; i < arrFunds.length; i++)
    {
      _safeMint(receiver, arrFunds[i]);
      minted.push(arrFunds[i]);
      totalMinted++;
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
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner() {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner 
  {

    
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
    
  }

  function getMinted() public view returns(uint256 [] memory)
  {
    return minted;

  }



}
