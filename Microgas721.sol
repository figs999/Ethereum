// SPDX-License-Identifier: UNLICENSED
// Copyright (c) 2021 Chance Santana-Wees

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract Microgas721 is Context, ERC721Pausable, Ownable {
    uint256 constant ADDRESS_MASK = 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 public nftSupply;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    // Mapping from token ID to owner address
    mapping(uint256 => uint256) private _owners;

    /// @notice Requires that the token exists.
    modifier tokenExists(uint256 tokenId) {
        require(_exists(tokenId), "Microgas721: Token doesn't exist");
        _;
    }

    /// @notice Can be called at the expense of gas during deployment to reduce gas prices for minters of NFTs (with IDs start_ through start_+count_) by 15k gas per NFT. 
    /// Must be called multiple times for large mints due to block gas limits.
    function prewarm(uint256 start_, uint256 count_) internal {
        for(uint i = start_; i < start_+count_; i++) {
            _owners[i] = 1;
        }
    }

    function ownerBlockOf(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Microgas721: owner query for nonexistent token");
        uint256 token = tokenId;
        uint256 owner = _owners[token];
        while(owner < 2) {
            owner = _owners[token--];
        }
        return owner;
    }

    function ownerAddress(uint256 ownerBlock) internal pure returns (address) {
        return address(uint160(ownerBlock & ADDRESS_MASK));
    }

    function getBlock(uint256 ownerBlock) internal pure returns (uint256) {
        return uint256(ownerBlock >> 160);
    }

    function tokenBlockNumber(uint256 tokenId) public view returns (uint256) {
        return getBlock(ownerBlockOf(tokenId));
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ownerAddress(ownerBlockOf(tokenId));
    }    

    function _exists(uint256 tokenId) internal view override returns (bool) {
        return nftSupply > tokenId;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        uint256 originalOwner = ownerBlockOf(tokenId);
        require(ownerAddress(originalOwner) == from, "Microgas721: transfer of token that is not own");
        require(to > address(1), "Microgas721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        //Implied ownership transfer requirement
        if(_owners[tokenId] < 2 && _owners[tokenId+1] < 2) {
            _owners[tokenId+1] = originalOwner;
        }

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);
        _owners[tokenId] = (getBlock(originalOwner) << 160) | uint160(to);

        emit Transfer(from, to, tokenId);
    }

    function _mintMultiple(address to, uint256 quantity) internal {
        require(to > address(1), "Microgas721: mint to the zero address");
        uint tokenId = nftSupply;

        _beforeTokenTransfer(address(0), to, nftSupply);
        _owners[tokenId] = (block.number << 160) | uint160(to);

        for(uint i = tokenId+1; i < tokenId + quantity; i++) {
            _beforeTokenTransfer(address(0), to, i);
            emit Transfer(address(0), to, i);
        }

        nftSupply = nftSupply + quantity;
    }

    function _mint(address to, uint256 tokenId) internal override {
        require(to > address(1), "Microgas721: mint to the zero address");
        require(!_exists(tokenId), "Microgas721: token already minted");
        require(nftSupply == tokenId, "Incorrect tokenID requested");

        _beforeTokenTransfer(address(0), to, tokenId);
        _owners[tokenId] = (block.number << 160) | uint160(to);
        nftSupply++;

        emit Transfer(address(0), to, tokenId);
    }

    function balanceOf(address) public view virtual override returns (uint256) {
        require(false, "Microgas721: Unsupported"); //Balance of is unneeded for ERC721 to function as intended.
        return type(uint256).max;
    }

    function _burn(uint256 tokenId) override internal virtual {
        uint256 ownerBlock = ownerBlockOf(tokenId);
        address owner = ownerAddress(ownerBlock);

        _beforeTokenTransfer(owner, address(0), tokenId);
        _beforeBurn(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        //Implied ownership transfer requirement
        if(_owners[tokenId] < 2 && _owners[tokenId+1] < 2) {
            _owners[tokenId+1] = ownerBlock;
        }

        _owners[tokenId] = 2;

        emit Transfer(owner, address(0), tokenId);
    }

    function _beforeBurn(uint256 tokenId) internal virtual { }

    /// @notice Pauses the contract.
    function pause() public onlyOwner {
        Pausable._pause();
    }

    /// @notice Unpauses the contract.
    function unpause() public onlyOwner {
        Pausable._unpause();
    }
}