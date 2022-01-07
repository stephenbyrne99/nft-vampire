// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MockNFT is Ownable, ERC721{

    uint256 public mintCounter;

    constructor(
      
    )
    ERC721("MOCK","Mock")
    {
        mintCounter = 0;
    }

    function mint() public returns (uint256 id){
        _safeMint(msg.sender,mintCounter);
        uint256 idMinted = mintCounter;
        mintCounter++;
        return idMinted;
    }

    function tokenURI(uint tokenId) public view override returns (string memory){
        return Strings.toString(tokenId);
    }

}