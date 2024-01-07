//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
// import "@openzeppelin/contracts/utils/Context.sol"; --not sure I need context for this contract, this is actually pulled in from Pausable

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions
/**
 * @title TaxLossHarvester
 * @author Trevor Foster
 * @notice This smart contract is designed to facilitate tax loss harvesting for holders of ERC721, ERC1155, and ERC20 tokens. 
 * The primary objective of this contract is to allow users to realize losses on their digital assets for tax purposes, 
 * in a compliant and automated manner. The contract is programmed to receive NFTs and ERC20 tokens from users. 
 * Upon receipt of the digital asset, the smart contract automatically returns a nominal amount of money to the user. 
 * This transaction is designed to establish a 'sale' or exchange event, thereby enabling the user to realize a capital loss on the asset.
 * The contract does not compute the loss value; users must calculate this based on their acquisition cost and the amount 
 * received from the smart contract. This loss can then potentially be used to offset capital gains in other areas, 
 * subject to the tax laws in the user's jurisdiction. 
 * 
 * This contract is intended for users who have a clear understanding of tax loss harvesting and its implications. 
 * It is advisable to consult with a tax professional before engaging in transactions intended for tax loss harvesting purposes.
 */

contract CoqInuRugCleaner is Ownable, Pausable, ReentrancyGuard {

    ////////////// 
    /// ERRORS ///
    //////////////

    error NoZeroAddress();
    error ArrayMismatchLengths();
    error CantBeZero(uint256);
    error InsufficientBalance(uint256, uint256);
    error ContractUnderFunded();
    error Denied();
    error UserNeedsMoreCoqInThem();
    error SameOwner(address);
    error OwnableInvalidOwner(address);

    ///////////////////////
    /// State Variables ///
    ///////////////////////

    address public immutable i_coq = 0x420FcA0121DC28039145009570975747295f2329; // Coq Token

    /// @notice The amount of COQ that the contract will pay to the user for each NFT or ERC20 token received
    uint256 public tokenPaymentAmount = 1000000000000000000000000; // 1,000,000 coq
    
    /// @notice The amount of AVAX that the contract will charge the user for each NFT or ERC20 token sent to it
    uint256 public serviceFee = 2000000000000000000000000; // 2,000,000 coq

    /// @notice The address that will receive the service fee
    address public roosterWallet; 

    ///@notice blacklist of addresses that cannot use the contract
    mapping(address => bool) public deniedList;


    //////////////
    /// EVENTS ///
    //////////////
    // Settings Events
    event roosterWalletChanged(address oldAddress, address newAddress);
    event ServiceFeeChanged(uint256 oldServiceFee, uint256 newServiceFee);
    event TokenPaymentAmountChanged(uint256 oldTokenPaymentAmount, uint256 newTokenPaymentAmount);
    event AVAXWithdrawn(address indexed user, uint256 amount);

    // Harvest Events
    event HarvestedERC20(address indexed user, address indexed token, uint256 amount);
    event HarvestedERC721(address indexed user, address indexed token, uint256 tokenId);
    event HarvestedERC1155(address indexed user, address indexed token, uint256 tokenId, uint256 amount);
    event HarvestedERC1155s(address indexed user, address[] tokens, uint256[] tokenIds, uint256[] amounts);
    event HarvestedERC721s(address indexed user, address[] tokens, uint256[] tokenIds);
    event HarvestedMultiERC20(address indexed user, address[] tokens, uint256[] amounts);

    // Withdraw Events
    event ERC20Withdrawn(address indexed user, address indexed token, uint256 amount);
    event ERC721Withdrawn(address indexed user, address indexed token, uint256 tokenId);
    event ERC1155Withdrawn(address indexed user, address indexed token, uint256 tokenId, uint256 amount);

    constructor(address _roosterWallet) {
        if (_roosterWallet == address(0)){
            revert NoZeroAddress();
        }

        roosterWallet = _roosterWallet;
    }

    // Function to receive Avax. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    /////////////
    /// ERC20 ///
    /////////////
    
    function harvestERC20(address _token, uint256 _amount) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender) || isDeniedListedWallet(_token)){
            revert Denied();
        }

        (bool success) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, serviceFee);
        require(success, "Failed to transfer ERC20 token to contract");


        (bool tokenharvested) = IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        require(tokenharvested, "Failed to transfer ERC20 token to contract");

        if(tokenPaymentAmount > IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }
        
        (bool sent) = IERC20(i_coq).transfer(msg.sender, tokenPaymentAmount);
        require(sent, "Payment to customer failed");

        emit HarvestedERC20(msg.sender, _token, _amount);
    }

    function harvestMultipleERC20(address[] calldata _tokens, uint256[] calldata _amounts) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender)){
            revert Denied();
        }
        if(_tokens.length != _amounts.length){
            revert ArrayMismatchLengths();
        }

        for(uint256 i = 0; i < _tokens.length; ++i){
            if(isDeniedListedWallet(_tokens[i])){
                revert Denied();
            }
            (bool success) = IERC20(_tokens[i]).transferFrom(msg.sender, address(this), _amounts[i]);
            require(success, "Failed to transfer ERC20 token to contract");

        }

        uint256 totalAmountToPayCustomer = tokenPaymentAmount * _tokens.length;
        uint256 totalServiceFeeAmount = serviceFee * _tokens.length;

        if(totalAmountToPayCustomer >= IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }

        if(totalServiceFeeAmount > IERC20(i_coq).balanceOf(msg.sender)){
            revert UserNeedsMoreCoqInThem();
        }

        // Send service fee to our wallet
        //@todo add gas limit -- def or maybe user transfer/send
        (bool paid) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, totalServiceFeeAmount);
        require(paid, "Failed to transfer ERC20 token to contract");

        // Send amount back to user
        //@todo add gas limit??
        (bool sent) = IERC20(i_coq).transfer(msg.sender, totalAmountToPayCustomer);
        require(sent, "Payment to customer failed");

        emit HarvestedMultiERC20(msg.sender, _tokens, _amounts);
    }

    //////////////
    /// ERC721 ///
    //////////////

    function harvestERC721(address _token, uint256 _tokenId) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender) || isDeniedListedWallet(_token)){
            revert Denied();
        }
        
        // Send service fee to our wallet
        (bool success) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, serviceFee);
        require(success, "Failed to transfer ERC20 token to contract");

        // Transfer tokens to TaxLossHarvest contract
        IERC721(_token).transferFrom(msg.sender, address(this), _tokenId);


        if(tokenPaymentAmount >= IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }
        // Send amount back to user
        (bool sent) = IERC20(i_coq).transfer(msg.sender, tokenPaymentAmount);
        require(sent, "Payment to customer failed");

        emit HarvestedERC721(msg.sender, _token, _tokenId);
    }

    function harvestMultipleERC721(address[] calldata _tokens, uint256[] calldata _tokenIds) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender)){
            revert Denied();
        }
        if(_tokens.length != _tokenIds.length){
            revert ArrayMismatchLengths();
        }

        for(uint256 i = 0; i < _tokens.length; ++i){    
            if(isDeniedListedWallet(_tokens[i])){
                revert Denied();
            }  
            // Transfer tokens to TaxLossHarvest contract
            IERC721(_tokens[i]).safeTransferFrom(msg.sender, address(this), _tokenIds[i]);
        }

        uint256 totalAmountToPayCustomer = tokenPaymentAmount * _tokens.length;
        uint256 totalServiceFeeAmount = serviceFee * _tokens.length;

       if(totalAmountToPayCustomer >= IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }

        if(totalServiceFeeAmount > IERC20(i_coq).balanceOf(msg.sender)){
            revert UserNeedsMoreCoqInThem();
        }

        // Send service fee to our wallet
        //@todo add gas limit -- def or maybe user transfer/send
        (bool paid) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, totalServiceFeeAmount);
        require(paid, "Failed to transfer ERC20 token to contract");

        // Send amount back to user
        //@todo add gas limit??
        (bool sent) = IERC20(i_coq).transfer(msg.sender, totalAmountToPayCustomer);
        require(sent, "Payment to customer failed");

        emit HarvestedERC721s(msg.sender, _tokens, _tokenIds);
        

    }

    ////////////////
    /// ERC 1155 ///
    ////////////////

    function harvestERC1155(address _token, uint256 _tokenId, uint256 _amount) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender) || isDeniedListedWallet(_token)){
            revert Denied();
        }
        
        // Send service fee to our wallet
        (bool success) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, serviceFee);
        require(success, "Failed to transfer ERC20 token to contract");

        // Transfer tokens to TaxLossHarvest contract
        IERC1155(_token).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

       if(tokenPaymentAmount >= IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }
        // Send amount back to user
        (bool sent) = IERC20(i_coq).transfer(msg.sender, tokenPaymentAmount);
        require(sent, "Payment to customer failed");

        emit HarvestedERC1155(msg.sender, _token, _tokenId, _amount);
    }

    function harvestMultipleERC1155(address[] calldata _tokens, uint256[] calldata _tokenIds, uint256[] calldata _amounts) external payable nonReentrant whenNotPaused{
        if(isDeniedListedWallet(msg.sender)){
            revert Denied();
        }

        if(_tokens.length != _tokenIds.length && _tokenIds.length != _amounts.length){
            revert ArrayMismatchLengths();
        }

        for(uint256 i = 0; i < _tokens.length; ++i){   
            if(isDeniedListedWallet(_tokens[i])){
                revert Denied();
            }                 
            // Transfer tokens to TaxLossHarvest contract
            IERC1155(_tokens[i]).safeTransferFrom(msg.sender, address(this), _tokenIds[i], _amounts[i], "");
        }

        uint256 totalAmountToPayCustomer = tokenPaymentAmount * _tokens.length;
        uint256 totalServiceFeeAmount = serviceFee * _tokens.length;

        if(totalAmountToPayCustomer >= IERC20(i_coq).balanceOf(address(this))){
            revert ContractUnderFunded();
        }

        if(totalServiceFeeAmount > IERC20(i_coq).balanceOf(msg.sender)){
            revert UserNeedsMoreCoqInThem();
        }

        // Send service fee to our wallet
        //@todo add gas limit -- def or maybe user transfer/send
        (bool paid) = IERC20(i_coq).transferFrom(msg.sender, roosterWallet, totalServiceFeeAmount);
        require(paid, "Failed to transfer ERC20 token to contract");

        // Send amount back to user
        //@todo add gas limit??
        (bool sent) = IERC20(i_coq).transfer(msg.sender, totalAmountToPayCustomer);
        require(sent, "Payment to customer failed");


        emit HarvestedERC1155s(msg.sender, _tokens, _tokenIds, _amounts);
    }



    ////////////////////////////////
    /// Withdraw Funcs For Owner ///
    ////////////////////////////////

    function withdrawAvax(address _to, uint256 _amount) external onlyOwner nonReentrant{
        if (_to == address(0)){
            revert NoZeroAddress();
        }

        if (_amount > address(this).balance){
            revert InsufficientBalance(address(this).balance, _amount);
        }
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send AVAXer");

        emit AVAXWithdrawn(_to, _amount);
    }

    function withdrawERC20Token(address _to, address _token, uint256 _amount) external onlyOwner nonReentrant{
        if (_to == address(0)){
            revert NoZeroAddress();
        }
        if (_amount > IERC20(_token).balanceOf(address(this))){
            revert InsufficientBalance(IERC20(_token).balanceOf(address(this)), _amount);
        }

        (bool sent) = IERC20(_token).transfer(_to, _amount);
        require(sent, "Failed ERC20 Token Transfer");

        emit ERC20Withdrawn(_to, _token, _amount);
    }

    function withdrawERC721(address _to, address _token, uint256 _tokenId) external onlyOwner nonReentrant{
        IERC721(_token).safeTransferFrom(address(this), _to, _tokenId);

        emit ERC721Withdrawn(_to, _token, _tokenId);
    }

    function withdrawERC1155(address _to, address _token, uint256 _tokenId, uint256 _amount) external onlyOwner nonReentrant{
        IERC1155(_token).safeTransferFrom(address(this), _to, _tokenId, _amount, "");

        emit ERC1155Withdrawn(_to, _token, _tokenId, _amount);
    }


    ////////////////////////////
    /// Edit State Variables ///
    ////////////////////////////

    function changeroosterWallet(address _newroosterWallet) external onlyOwner {
        if (_newroosterWallet == address(0)){
            revert NoZeroAddress();
        }
        address oldAddress = roosterWallet;
        roosterWallet = _newroosterWallet;

        emit roosterWalletChanged(oldAddress, _newroosterWallet);
    }

    function changeServiceFee(uint256 _newServiceFee) external onlyOwner {
        if (_newServiceFee == 0){
            revert CantBeZero(_newServiceFee);
        }
        uint256 oldServiceFee = serviceFee;
        serviceFee = _newServiceFee;

        emit ServiceFeeChanged(oldServiceFee, _newServiceFee);
    }

    function changeTokenPaymentAmount(uint256 _newTokenPaymentAmount) external onlyOwner {
        if (_newTokenPaymentAmount == 0){
            revert CantBeZero(_newTokenPaymentAmount);
        }
        uint256 oldTokenPaymentAmount = tokenPaymentAmount;
        tokenPaymentAmount = _newTokenPaymentAmount;

        emit TokenPaymentAmountChanged(oldTokenPaymentAmount, _newTokenPaymentAmount);
    }   

    function deny(address _address, bool _isDenied) external onlyOwner {
        deniedList[_address] = _isDenied;
    }


    ///////////////////////
    /// Admin Functions ///
    ///////////////////////
    function transferOwnership(address newOwner) public override onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        address oldOwner = owner();

        if(newOwner == oldOwner){
            revert SameOwner(oldOwner);
        }

        _transferOwnership(newOwner);

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    //////////////////////////////
    /// safeTransfer receivers ///
    //////////////////////////////

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    ///////////////////////////////
    /// Getter & View Functions ///
    ///////////////////////////////

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getroosterWalletAddress() public view returns (address) {
        return roosterWallet;
    }

    function getCurrentServiceFee() public view returns(uint256) {
        return serviceFee;
    }

    function getTokenPaymentAmount() public view returns(uint256){
        return tokenPaymentAmount;
    }

    function isPaused() public view returns (bool) {
        return paused();
    }

    function isDeniedListedWallet(address _address) public view returns (bool) {
        return deniedList[_address];
    }
}
