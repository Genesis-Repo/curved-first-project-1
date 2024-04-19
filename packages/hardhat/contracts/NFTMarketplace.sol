// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721, ERC721Enumerable, Ownable {
    uint256 public nextTokenId;
    uint256 public listingPrice;

    // Mapping from token ID to its price
    mapping(uint256 => uint256) private tokenPrice;

    event TokenListed(address indexed owner, uint256 indexed tokenId, uint256 price);
    event TokenSold(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 price);

    constructor(string memory name_, string memory symbol_, uint256 _listingPrice) ERC721(name_, symbol_) {
        nextTokenId = 1;
        listingPrice = _listingPrice;
    }

    function listToken(uint256 price) external {
        require(price >= listingPrice, "Price must be at least the listing price");
        _mint(msg.sender, nextTokenId);
        tokenPrice[nextTokenId] = price;
        emit TokenListed(msg.sender, nextTokenId, price);
        nextTokenId++;
    }

    function buyToken(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(msg.value >= tokenPrice[tokenId], "Insufficient funds sent");

        address seller = ownerOf(tokenId);
        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);
        
        emit TokenSold(msg.sender, seller, tokenId, tokenPrice[tokenId]);
        tokenPrice[tokenId] = 0;
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return tokenPrice[tokenId];
    }

    function setListingPrice(uint256 _listingPrice) external onlyOwner {
        listingPrice = _listingPrice;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}