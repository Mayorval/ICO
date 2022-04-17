//SPDX-License-Identifier: MIT
//Crypto Devs Token Contract Address: 0xbEDbd082515520882AbA307CD8779d614841eaba
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //Price of one Crypto Dev token
    uint256 public constant tokenPrice = 0.001 ether;

       //Each NFT would give the user 10 tokens
      // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
      // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
      // is actually equal to (10 ^ -18) tokens.
      // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
      // More information on this can be found in the Freshman Track Cryptocurrency tutorial.

    uint256 public constant tokensPerNFT = 10 * 10**18;
    //the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    //Mapping to keep track of which tokenIds have been claimed;
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
       * @dev Mints `amount` number of CryptoDevTokens
       * Requirements:
       * - `msg.value` should be equal or greater than the tokenPrice * amount
    */
    function mint(uint256 amount) public payable {
        //the value of ether should be equal or greater than tokenPrice * amount;
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        //total tokens + amount  <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply available");
        //call the internal function from Openzeppelin's contract
        _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
         address sender = msg.sender;
         //Get the number of CryptoDev NFTs held by a given address
         uint256 balance = CryptoDevsNFT.balanceOf(sender);
         //if the balance is zero, reverse the transaction
         require(balance > 0, "You do not own any Crypto Dev NFTs");
         //amount keeps track of number of unclaimed tokenIds
         uint256 amount = 0;
         //loop over the balance and get the token ID owned by 'sender' at  a given 'index' of its token list.
         for (uint256 i = 0; i < balance; i++) {
             uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender,i);
             //if the tokenId has not been claimed, increase the amount
             if (!tokenIdsClaimed[tokenId]){
                 amount += 1;
                 tokenIdsClaimed[tokenId] = true;
             }
         }
         //if all the token Ids have been claimed, revert the transaction;
         require(amount > 0,"You have already claimed all the tokens");
         //call the internal function from Openzeppelin's ERC20 contract
         //Mint (amount *10) tokens for each NFT
         _mint(msg.sender, amount * tokensPerNFT);
    }

    //Function to receive Ether. msg.data must be empty
    receive() external payable {}

    //Fallback function is when msg.data is not empty


}