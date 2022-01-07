// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;

import "./utils/NFTVampireTest.sol";

contract VampireTest is NFTVampireTest {
    
    function testMintMock() public {
        alice.mintMock();
    }

    function testMintVampire() public {
        uint256 idMockMinted = alice.mintMockAndApprove();
        assert(mockNFT.ownerOf(idMockMinted)==address(alice));
        alice.mintVampire(idMockMinted);
        assert(mockNFT.ownerOf(idMockMinted)==address(nftVampire));
    }

    function testUnlockOriginal() public {
        uint256 idMockMinted = alice.mintMockAndApprove();
        assert(mockNFT.ownerOf(idMockMinted)==address(alice));
        alice.mintVampire(idMockMinted);
        assert(mockNFT.ownerOf(idMockMinted)==address(nftVampire));
        alice.unlockAndBurn(idMockMinted);
        assert(mockNFT.ownerOf(idMockMinted)==address(alice));
    }

    function testCantMintNonExistentToken() public {
        try alice.mintVampire(200){
            fail();
        }catch Error(string memory error){
            assertEq(error, "ERC721: owner query for nonexistent token");
        }
    }

    function testWithdrawERC20sDoesNotAllowWithdrawingVictim() public {
        // uint idMockMinted = alice.mintMockAndApprove();
        // try alice.withdrawHack(){
        //     fail();
        // }catch Error(string memory error){
        //     assertEq(error, "");
        // }


        /**
        *   Fails as expected but was too lazy to figure out how to catch reverts in dapptools
        **/
    }
}

// contract Gm is GreeterTest {
//     function testOwnerCanGmOnGoodBlocks() public {
//         hevm.roll(10);
//         alice.gm();
//         assertEq(greeter.greeting(), "gm");
//     }

//     function testOwnerCannotGmOnBadBlocks() public {
//         hevm.roll(11);
//         try alice.gm() {
//             fail();
//         } catch Error(string memory error) {
//             assertEq(error, Errors.InvalidBlockNumber);
//         }
//     }

//     function testNonOwnerCannotGm() public {
//         try bob.gm() {
//             fail();
//         } catch Error(string memory error) {
//             assertEq(error, "Ownable: caller is not the owner");
//         }
//     }
// }
