// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import '../lib/forge-std/src/Test.sol';
///home/funkornaut/scaffold-eth-2/packages/hardhat/contracts/Mocks/MockERC20.sol
import {Harvester} from "../contracts/Harvester.sol";
import {MockERC20} from "../contracts/Mocks/MockERC20.sol";
import {MockERC721} from "../contracts/Mocks/MockERC721.sol";
import {MockERC1155} from "../contracts/Mocks/MockERC1155.sol";

contract HarvesterTest is Test {
    Harvester public harvester;

    MockERC20 public mockERC20;
    MockERC721 public mockERC721;
    MockERC1155 public mockERC1155;

    address public companyWallet = makeAddr("companyWallet");
    address public userWallet = makeAddr("userWallet");
    // uint256 public minEthToHarvest = 0.00007 ether;
    // uint256 public serviceFee = 0.045 ether; //0.045 ether ~ $100 as of 2023 - 12 - 15
    // uint256 public tokenPaymentAmount = 7000 gwei; // ~ $0.01 as of 2022-10-19
    
    uint256 public tokenPaymentAmount = 0.0004269 ether; // about $1 when ETH id ~$2,100 
    
    /// @notice The amount of ETH that the contract will charge the user for each NFT or ERC20 token sent to it
    uint256 public serviceFee = 0.0069 ether;
    ///@notice the minimum amount of eth that needs to be sent for a loss harvest in wei
    uint256 public minEthToHarvest = 0.0005 ether;

    uint256 dealtAmount = 0.0004269 ether;


    function setUp() public {
        harvester = new Harvester(companyWallet);
        vm.deal(userWallet, 1 ether);
        vm.deal(address(harvester), dealtAmount);
        
        //@todo maybe move minting tokens into their own function so testing w/ -vvvv is not so long
        mockERC20 = new MockERC20("Mock20", "M20");
        mockERC20.mint(userWallet, 1000); // mint 1000 tokens to userWallet

        mockERC721 = new MockERC721("Mock NFT", "MNFT");

        for(uint i; i < 5; ++i){
            mockERC721.safeMint(userWallet); // mint tokenId 0-4 to userWallet
        }
     

        mockERC1155 = new MockERC1155();

        mockERC1155.mint(userWallet, 5); // mint 5 tokens of tokenId 1 to userWallet
        
    }

    ////////////////////
    /// Helper Funcs ///
    ////////////////////

    function mintMultiERC20() public returns (address[] memory, uint256[] memory) {
        uint256 tokenCount = 5;
        address[] memory tokens = new address[](tokenCount);
        uint256[] memory amounts = new uint256[](tokenCount); // Array for amounts

        for (uint i = 0; i < tokenCount; i++) {
            MockERC20 token = new MockERC20("Mock20", "M20");
            uint256 mintAmount = 1000; // Example amount
            token.mint(userWallet, mintAmount);
            tokens[i] = address(token);
            amounts[i] = mintAmount; // Fill the amounts array
        }

        return (tokens, amounts);
    }

    function mintMultiERC721() public returns (address[] memory, uint256[] memory) {
        uint256 tokenCount = 5;
        address[] memory tokens = new address[](tokenCount);
        uint256[] memory ids = new uint256[](tokenCount); // Array for amounts

        for (uint i = 0; i < tokenCount; i++) {
            MockERC721 token = new MockERC721("Mock NFT", "MNFT");
            token.safeMint(userWallet);
            tokens[i] = address(token);
            ids[i] = 0; 
        }

        return (tokens, ids);
    }
//function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual

    function mintMultiERC1155() public returns (address[] memory, uint256[] memory, uint256[] memory) {
        uint256 tokenCount = 5;
        address[] memory tokens = new address[](tokenCount);
        uint256[] memory ids = new uint256[](tokenCount); // Array for amounts
        uint256[] memory amounts = new uint256[](tokenCount); // Array for amounts

        for (uint i = 0; i < tokenCount; i++) {
            MockERC1155 token = new MockERC1155();
            uint256 amount = 5;
            token.mint(userWallet, amount);
            tokens[i] = address(token);
            ids[i] = 0; // Fill the amounts array
            amounts[i] = amount;
        }

        return (tokens, ids, amounts);
    }


    //////////////////
    /// Test SetUp ///
    //////////////////

    function test_setUp() public {
        assertEq(harvester.companyWallet(), companyWallet);
        assertEq(harvester.serviceFee(), serviceFee);
        assertEq(harvester.minEthToHarvest(), minEthToHarvest);
        assertEq(address(harvester).balance, tokenPaymentAmount);

        assertEq(mockERC20.balanceOf(userWallet), 1000);
        assertEq(mockERC721.balanceOf(userWallet), 5);
        assertEq(mockERC1155.balanceOf(userWallet, 1), 5);
        assertEq(mockERC1155.balanceOf(userWallet, 2), 5);
        assertEq(mockERC1155.balanceOf(userWallet, 3), 5);
    }

    /////////////////////////////////////
    /// Can Recieve ETH & Token Tests ///
    /////////////////////////////////////

    function test_canRecieveEth() public {
        address sender = makeAddr("sender");
        vm.deal(sender, 1 ether);
        assertEq(address(sender).balance, 1 ether);

        vm.prank(sender);
        payable(harvester).transfer(1 ether);

        assertEq(address(sender).balance, 0 ether);
        assertEq(address(harvester).balance, 1 ether + tokenPaymentAmount);
    }   

    function test_canRecieveERC20() public {
        vm.prank(userWallet);
        mockERC20.transfer(address(harvester), 500);

        assertEq(mockERC20.balanceOf(userWallet), 500);
        assertEq(mockERC20.balanceOf(address(harvester)), 500);
    }

    function test_canReceiveERC721() public {
        vm.startPrank(userWallet);
        mockERC721.approve(address(harvester), 1);
        mockERC721.safeTransferFrom(userWallet, address(harvester), 1);

        assertEq(mockERC721.balanceOf(userWallet), 4);
        assertEq(mockERC721.balanceOf(address(harvester)), 1);
    }

    function test_canReceieveERC1155() public {
        vm.startPrank(userWallet);
        mockERC1155.setApprovalForAll(address(harvester), true);
        mockERC1155.safeTransferFrom(userWallet, address(harvester), 0, 1, "");

        assertEq(mockERC1155.balanceOf(userWallet, 0), 4);
        assertEq(mockERC1155.balanceOf(address(harvester), 0), 1);
    }

    /////////////////////////////////
    /// Test Harvesting Functions ///
    /////////////////////////////////

    function test_harvestEth() public {
        vm.startPrank(userWallet);
    
        uint256 amountToHarvest = 0.5 ether + serviceFee; // 0.545 ether 
        harvester.harvestEth{value: amountToHarvest}();
        // console2.log("userWallet balance: ", address(userWallet).balance);
        // console2.log("harvester balance: ", address(harvester).balance);
        // console2.log("companyWallet balance: ", address(companyWallet).balance);
        // console2.log("serviceFee: ", serviceFee);

        assertEq(companyWallet.balance, serviceFee);
        assertEq(address(harvester).balance, (0.5 ether));
        assertEq(userWallet.balance, ((1 ether - amountToHarvest) + tokenPaymentAmount)); 
    }

    function test_harvestERC20() public {
        vm.startPrank(userWallet);
        mockERC20.approve(address(harvester), 500);
        harvester.harvestERC20{value: serviceFee}(address(mockERC20), 500);

        assertEq(mockERC20.balanceOf(userWallet), 500);
        assertEq(mockERC20.balanceOf(address(harvester)), 500);
        // ether balances 
        assertEq(companyWallet.balance, serviceFee);
        assertEq(address(harvester).balance, 0);
        console2.log("userWallet balance: ", address(userWallet).balance);
        assertEq(userWallet.balance, (1 ether - serviceFee + tokenPaymentAmount));
    }

    function test_harvestERC721() public {
        vm.startPrank(userWallet);
        mockERC721.approve(address(harvester), 1);
        harvester.harvestERC721{value: serviceFee}(address(mockERC721), 1);

        assertEq(mockERC721.balanceOf(userWallet), 4);
        assertEq(mockERC721.balanceOf(address(harvester)), 1);
        // ether balances 
        assertEq(companyWallet.balance, serviceFee);
        assertEq(address(harvester).balance, 0);
        assertEq(userWallet.balance, (1 ether - serviceFee + tokenPaymentAmount));
    }

    function test_harvestERC1155() public {
        vm.startPrank(userWallet);
        mockERC1155.setApprovalForAll(address(harvester), true);
        harvester.harvestERC1155{value: serviceFee}(address(mockERC1155), 0, 1);

        // 1155 balances
        assertEq(mockERC1155.balanceOf(userWallet, 0), 4);
        assertEq(mockERC1155.balanceOf(address(harvester), 0), 1);

        // ether balances 
        assertEq(companyWallet.balance, serviceFee);
        assertEq(address(harvester).balance, dealtAmount - tokenPaymentAmount);
        assertEq(userWallet.balance, (1 ether - serviceFee + tokenPaymentAmount));
    }

    //////////////////////////
    /// Test Multi Harvest ///
    //////////////////////////

    function test_harvestMultipleERC20() public {
        vm.deal(address(harvester), 1 ether);
        (address[] memory tokens, uint256[] memory amounts) = mintMultiERC20();

        vm.startPrank(userWallet);
        for (uint i = 0; i < tokens.length; i++) {
            MockERC20(tokens[i]).approve(address(harvester), amounts[i]); // Approve all for harvest
        }

        uint256 totalServiceFee = serviceFee * tokens.length;
        uint256 totalTokenPaymentAmount = tokenPaymentAmount * tokens.length;
        // Call your harvestMultipleERC20s function with the tokens and amounts arrays
        harvester.harvestMultipleERC20{value: totalServiceFee}(tokens, amounts);

        vm.stopPrank();
        for (uint i = 0; i < tokens.length; i++) {
            assertEq(MockERC20(tokens[i]).balanceOf(userWallet), 0);
            assertEq(MockERC20(tokens[i]).balanceOf(address(harvester)), amounts[i]);
        }

        //console2.log("companyWallet balance: ", address(companyWallet).balance);
        assertEq(companyWallet.balance, totalServiceFee);
        //console2.log("harvester balance: ", address(harvester).balance);
        assertEq(address(harvester).balance, (1 ether - totalTokenPaymentAmount));
        assertEq(userWallet.balance, (1 ether - totalServiceFee + totalTokenPaymentAmount));
    }

    function test_harvestMultipleERC721() public {
        vm.deal(address(harvester), 1 ether);
        (address[] memory tokens, uint256[] memory ids) = mintMultiERC721();

        vm.startPrank(userWallet);
        for (uint i = 0; i < tokens.length; i++) {
            MockERC721(tokens[i]).approve(address(harvester), ids[i]); // Approve all for harvest
        }

        uint256 totalServiceFee = serviceFee * tokens.length;
        uint256 totalTokenPaymentAmount = tokenPaymentAmount * tokens.length;

        // Call your harvestMultipleERC721s function with the tokens and ids arrays
        harvester.harvestMultipleERC721{value: totalServiceFee}(tokens, ids);

        console2.log("token1 address: ", tokens[0]);
        console2.log("token2 address: ", tokens[1]);

        vm.stopPrank();
        for (uint i = 0; i < tokens.length; i++) {
            assertEq(MockERC721(tokens[i]).balanceOf(userWallet), 0);
            assertEq(MockERC721(tokens[i]).balanceOf(address(harvester)), 1);
        }

        assertEq(companyWallet.balance, totalServiceFee);
        assertEq(address(harvester).balance, 1 ether - totalTokenPaymentAmount);
        assertEq(userWallet.balance, (1 ether - totalServiceFee + totalTokenPaymentAmount));
    }

    function test_harvestMultipleERC1155() public {
        vm.deal(address(harvester), 1 ether);
        (address[] memory tokens, uint256[] memory ids, uint256[] memory amounts) = mintMultiERC1155();

        vm.startPrank(userWallet);
        for (uint i = 0; i < tokens.length; i++) {
            MockERC1155(tokens[i]).setApprovalForAll(address(harvester), true); // Approve all for harvest
            console2.log("token address: ", tokens[i]);
        }
        
        uint256 totalServiceFee = serviceFee * tokens.length;
        uint256 totalTokenPaymentAmount = tokenPaymentAmount * tokens.length;

        // Call your harvestMultipleERC1155s function with the tokens, ids, and amounts arrays 
        harvester.harvestMultipleERC1155{value: totalServiceFee}(tokens, ids, amounts);

        vm.stopPrank();
        for (uint i = 0; i < tokens.length; i++) {
            assertEq(MockERC1155(tokens[i]).balanceOf(userWallet, ids[i]), 0);
            assertEq(MockERC1155(tokens[i]).balanceOf(address(harvester), ids[i]), amounts[i]);
        }

        assertEq(companyWallet.balance, totalServiceFee);
        assertEq(address(harvester).balance, 1 ether - totalTokenPaymentAmount);
        assertEq(userWallet.balance, (1 ether - totalServiceFee + totalTokenPaymentAmount));
    }

    //////////////////////
    /// Withdraw Tests ///
    //////////////////////

    function test_withdrawEth() public {
        vm.deal(address(harvester), 1 ether);
        assertEq(address(harvester).balance, 1 ether);

        harvester.withdrawEth(address(companyWallet), 1 ether);
        console2.log("company wallet: ", address(companyWallet));

        assertEq(address(harvester).balance, 0 ether);
        assertEq(companyWallet.balance, 1 ether);
    }

    function test_withdrawERC20() public {
        test_harvestERC20();
        vm.stopPrank();

        harvester.withdrawERC20Token(address(companyWallet), address(mockERC20), 500);

        assertEq(mockERC20.balanceOf(address(harvester)), 0);
        assertEq(mockERC20.balanceOf(address(companyWallet)), 500);
    }
    
    function test_withdrawERC721() public {
        test_harvestERC721();
        vm.stopPrank();

        harvester.withdrawERC721(address(companyWallet), address(mockERC721), 1);

        assertEq(mockERC721.balanceOf(address(harvester)), 0);
        assertEq(mockERC721.balanceOf(address(companyWallet)), 1);
    }

    function test_withdrawERC1155() public {
        test_harvestERC1155();
        vm.stopPrank();

        harvester.withdrawERC1155(address(companyWallet), address(mockERC1155), 1, 1);

        assertEq(mockERC1155.balanceOf(address(harvester), 1), 0);
        assertEq(mockERC1155.balanceOf(address(companyWallet), 1), 1);
    }

    ////////////////////////
    /// Test Edit States ///
    ////////////////////////

    function test_changeCompanyWallet() public {
       // address oldAddress = harvester.getCompanyWalletAddress();
        harvester.changeCompanyWallet(address(1));
        //address newAddress = harvester.getCompanyWalletAddress();
        assertEq(harvester.getCompanyWalletAddress(), address(1));
    }

    function test_changeServiceFee() public {
        harvester.changeServiceFee(0.69 ether);
        assertEq(harvester.getCurrentServiceFee(), 0.69 ether);
    }

    function test_changeTokenPaymentAmount() public {
        harvester.changeTokenPaymentAmount(9999 gwei);
        assertEq(harvester.getTokenPaymentAmount(), 9999 gwei);
    }

    function test_changeMinEthToHarvest() public {
        harvester.changeMinEthToHarvest(0.420 ether);
        assertEq(harvester.getMinEthToHarvest(), 0.420 ether);
    }

    function test_deniedList() public {
        assertEq(harvester.isdeniedListed(userWallet), false);
        harvester.deny(userWallet, true);
        assertEq(harvester.isdeniedListed(userWallet), true);
    }

    ///////////////////////
    /// Pause Func Test ///
    ///////////////////////

    function test_pause() public {
        assertEq(harvester.isPaused(), false);
        harvester.pause();
        assertEq(harvester.isPaused(), true);
    }

    function test_unpause() public {
        harvester.pause();
        assertEq(harvester.isPaused(), true);
        harvester.unpause();
        assertEq(harvester.isPaused(), false);
    }
}
