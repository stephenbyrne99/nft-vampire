// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


/// @title A contract to vampire attack an NFT project
/// @author ste.eth / cherry
/// @notice go wild. Art gud. Project Owners often bad.
/// @dev Not finished yet - nor tested - pls if forking use with caution. Also need to gas opt.
contract NFTVampire is Ownable, ERC721, IERC721Receiver {

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          CONSTANTS
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    IERC721Metadata immutable victimNFT;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          VARIABLES
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    mapping(uint256 => address) idToOwner;

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          MODIFIERS
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    modifier requireVictimNftOwner(uint256 tokenId){
        require(victimNFT.ownerOf(tokenId) == msg.sender, "Victim: Not Owner");
        _;
    }

    modifier requireVampireNftOwner(uint256 tokenId){
        require(idToOwner[tokenId] == msg.sender, "Vampire: Not Owner");
        _;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    constructor(
        IERC721Metadata _victimNFT,
        string memory newName,
        string memory newSymbol
    )
    ERC721(newName, newSymbol)
    {
        victimNFT = _victimNFT;
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                          vNFT FUNCTIONALITY
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice Mints vampireNFT (vNFT) and locks victim NFT
    /// @dev requires approval of the NFT before calling function
    /// @param tokenId Token ID to mine
    function mint(uint tokenId) 
        public 
        requireVictimNftOwner(tokenId)
    { 

        /// Transfer NFT
        victimNFT.safeTransferFrom(msg.sender,address(this),tokenId);

        /// Set owner
        idToOwner[tokenId] = msg.sender;

        /// Mint vNFT
        _mint(msg.sender,tokenId);

    }

    /// @notice Unlocks underlying victim NFT and burns the vampire NFT (vNFT)
    /// @param tokenId Token ID to unlock and burn.
    function unlockAndBurn(uint tokenId) 
        public 
        requireVampireNftOwner(tokenId)
    {

        /// Transfer NFT
        victimNFT.safeTransferFrom(address(this),msg.sender,tokenId);

        /// Remove owner
        idToOwner[tokenId] = address(0);

        /// Burn vNFT
        _burn(tokenId);
    }

    /// @notice Calls the victim contract to resolve the tokenURI
    /// @param tokenId The Id of the token to fetch.
    /// @return The token URI as a string
    function tokenURI(uint256 tokenId) public view override returns (string memory){
        return victimNFT.tokenURI(tokenId);
    }

    /// @dev See {IERC721-safeTransferFrom}.
    function onERC721Received(address, address, uint256, bytes memory) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                         WITHDRAWALS
    //////////////////////////////////////////////////////////////////////////////////////////////////////

    /// @notice function to withdraw any fees/donations earned from the collection which are ERC20s
    /// @param tokenToWithdraw The ERC20 address being withdrawn.
    /// @param toAddress The address to withdraw to.
    function withdrawERC20s(
        IERC20 tokenToWithdraw,
        address toAddress
    ) public onlyOwner {
        tokenToWithdraw.transfer(
            toAddress,
            tokenToWithdraw.balanceOf(address(this))
        );
    }

    /// @notice function to withdraw any fees/donations earned from the collection in Ether
    /// @param toAddress The address to withdraw to.
    function withdrawEth(
        address toAddress
    ) public onlyOwner {
        payable(toAddress).transfer(address(this).balance);
    }


    /// @notice Payable fallback function to be able to recieve Ether
    receive() external payable {}
}
