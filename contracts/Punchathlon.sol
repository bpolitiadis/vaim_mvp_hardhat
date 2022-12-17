//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// import "hardhat/console.sol";

contract Punchathlon is ERC721Enumerable, ERC721URIStorage {
    enum FighterClass {
        JiuJitsu,
        KickBoxing,
        Judo,
        Wrestling,
        MuayThai
    }

    enum Rarities {
        Common,
        Uncommon,
        Rare,
        Legendary
    }

    struct Stats {
        uint8 strength;
        uint8 stamina;
        uint8 technique;
        uint8 victories;
        FighterClass fightStyle;
        Rarities rarity;
    }

    struct TraitAdjustmentByRarity {
        int8 low;
        int8 high;
    }

    // max number of fighter NFTs
    uint256 private tokenId;
    uint256 private maxTokenIds = 1000;
    uint256 private _price = 0.01 * 1000000000000000000;

    mapping(bytes => Stats) baseStats;
    mapping(bytes => TraitAdjustmentByRarity) rarityAdjustments;
    mapping(uint256 => Stats) tokenToStats;

    constructor() ERC721("Punchathlon", "PUNCHR") {
        tokenId = 0;
        initBaseStats();
    }

    function initBaseStats() internal {
        Stats memory jiuJitsu = Stats(80, 80, 20, 0, FighterClass.JiuJitsu, Rarities.Common);
        Stats memory kickBoxing = Stats(60, 60, 60, 0, FighterClass.KickBoxing, Rarities.Common);
        Stats memory judo = Stats(40, 60, 80, 0, FighterClass.Judo, Rarities.Common);
        Stats memory wrestling = Stats(20, 100, 60, 0, FighterClass.Wrestling, Rarities.Common);
        Stats memory muayThai = Stats(100, 40, 40, 0, FighterClass.MuayThai, Rarities.Common);

        baseStats[abi.encode(FighterClass.JiuJitsu)] = jiuJitsu;
        baseStats[abi.encode(FighterClass.KickBoxing)] = kickBoxing;
        baseStats[abi.encode(FighterClass.Judo)] = judo;
        baseStats[abi.encode(FighterClass.Wrestling)] = wrestling;
        baseStats[abi.encode(FighterClass.MuayThai)] = muayThai;

        TraitAdjustmentByRarity memory common = TraitAdjustmentByRarity(-20, 0);
        TraitAdjustmentByRarity memory uncommon = TraitAdjustmentByRarity(-15, 5);
        TraitAdjustmentByRarity memory rare = TraitAdjustmentByRarity(-10, 10);
        TraitAdjustmentByRarity memory legendary = TraitAdjustmentByRarity(-5, 15);

        rarityAdjustments[abi.encode(Rarities.Common)] = common;
        rarityAdjustments[abi.encode(Rarities.Uncommon)] = uncommon;
        rarityAdjustments[abi.encode(Rarities.Rare)] = rare;
        rarityAdjustments[abi.encode(Rarities.Legendary)] = legendary;
    }

    function getFighterClassBaseStats(string memory fighterClassName) internal returns (Stats memory) {
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("JiuJitsu")))
            return baseStats[abi.encode(FighterClass.JiuJitsu)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("KickBoxing")))
            return baseStats[abi.encode(FighterClass.KickBoxing)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("Judo"))) return baseStats[abi.encode(FighterClass.Judo)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("Wrestling")))
            return baseStats[abi.encode(FighterClass.Wrestling)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("MuayThai")))
            return baseStats[abi.encode(FighterClass.MuayThai)];

        return Stats(0, 0, 0, 0, FighterClass.KickBoxing, Rarities.Common);
    }

    function getAdjustmentByRarity(string memory rarity) internal returns (TraitAdjustmentByRarity memory) {
        if (keccak256(bytes(rarity)) == keccak256(bytes("Common"))) return rarityAdjustments[abi.encode(Rarities.Common)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Uncommon")))
            return rarityAdjustments[abi.encode(Rarities.Uncommon)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Rare"))) return rarityAdjustments[abi.encode(Rarities.Rare)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Legendary")))
            return rarityAdjustments[abi.encode(Rarities.Legendary)];

        return TraitAdjustmentByRarity(0, 0);
    }

    function mint(string memory _class, string memory _imageURI) public payable {
        require(tokenId < maxTokenIds, "Exceed maximum fighters supply");
        require(msg.value >= _price, "Ether sent is not correct");

        tokenToStats[tokenId] = getFighterClassBaseStats(_class);

        _safeMint(msg.sender, tokenId);

        _setTokenURI(tokenId, _imageURI);

        tokenId++;
    }

    // Overrides

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return ERC721.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /* firstTokenId */,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721._beforeTokenTransfer(from, to, 1, batchSize);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        return ERC721._burn(tokenId);
    }

    function getFighterStats(uint256 tokenId) public returns (Stats memory) {
        return tokenToStats[tokenId];
    }

    function getTokenId() public view returns (uint256) {
        return tokenId;
    }

    function getMaxTokenIds() public view returns (uint256) {
        return maxTokenIds;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }
}
