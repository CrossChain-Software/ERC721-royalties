// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// just start with a base 721 and 165 contract
// then move onto adding the custom functions

contract Template is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    // create token counter
    Counters.Counter private _tokenIdCounter;

    uint256 public mintPrice = 0.05 ether;
    uint256 public MAX_SUPPLY = 10000;

    constructor() ERC721("Template", "TMP") {}

    // will need to add a function to set the baseURI?
    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    // add onlyOwner modifier to pause() to pause the mint
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // anyone can mint- because it is payable, it shows up as red on Remix
    function safeMint(address to) public payable {
        require(totalSupply() < MAX_SUPPLY, "Cannot mint more than the max supply");
        require(msg.value >= mintPrice, "Not enough ether sent");
        _tokenIdCounter.increment(); // start at 1
        _safeMint(to, _tokenIdCounter.current());
    }

    function beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // required overrides
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes64 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // retrieve ether from minting that is stored in the contract state
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Balance needs to be greater than 0 to withdraw");
        payable(owner()).transfer(address(this).balance);
    }
}