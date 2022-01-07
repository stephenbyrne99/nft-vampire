// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import "ds-test/test.sol";

import "../../NFTVampire.sol";
import "../../mocks/MockNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Hevm.sol";

contract User is IERC721Receiver {
    NFTVampire internal nftVampire;
    MockNFT internal mockNFT;

    constructor(NFTVampire _NFTVampire, MockNFT _mockNFT) {
        nftVampire = NFTVampire(_NFTVampire);
        mockNFT = MockNFT(_mockNFT);
    }

    function onERC721Received(address, address, uint256, bytes memory) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function mintMock() public returns (uint256 id){
        uint256 id = mockNFT.mint();
        return id;
    }

    function mintMockAndApprove() public returns (uint256 id){
        uint256 id = mockNFT.mint();
        mockNFT.approve(
            address(nftVampire),
            id
        );
        return id;
    }

    function unlockAndBurn(uint id) public {
        nftVampire.unlockAndBurn(id);
    }

    function mintVampire(uint256 id) public {
        nftVampire.mint(id);
    }

    function withdrawHack() public {
        nftVampire.withdrawERC20s(
            IERC20(address(mockNFT)),
            address(this)
        );
    }


    // function greet(string memory greeting) public {
    //     vampireNFT.greet(greeting);
    // }

    // function gm() public {
    //     vampireNFT.gm();
    // }
}

abstract contract NFTVampireTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    // contracts
    NFTVampire internal nftVampire;
    MockNFT internal mockNFT;

    // users
    User internal alice;

    function setUp() public virtual {

        /// @dev contract setup for testing
        mockNFT = new MockNFT();
        nftVampire = new NFTVampire(
            mockNFT,
            "vNFT",
            "vNFT"
        );
        
        alice = new User(nftVampire, mockNFT);
        nftVampire.transferOwnership(address(alice));
    }
}
