//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Punchathlon is ERC721Enumerable, ERC721URIStorage {
    // Enum representing different fighter classes
    enum FighterClass {
        JiuJitsu,
        KickBoxing,
        Judo,
        Wrestling,
        MuayThai
    }

    // Enum representing different rarities of fighters
    enum Rarities {
        Common,
        Uncommon,
        Rare,
        Legendary
    }

    // Struct representing the stats of a fighter
    struct Stats {
        uint8 strength;
        uint8 stamina;
        uint8 technique;
        uint8 victories;
        FighterClass fightStyle;
        Rarities rarity;
    }

    // Struct representing trait adjustments based on rarity
    struct TraitAdjustmentByRarity {
        int8 low;
        int8 high;
    }

    // The current token ID for creating new fighters
    uint256 private tokenId;
    // The maximum number of NFT fighters that can be created
    uint256 private maxTokenIds = 1000;
    // The mint price to create a new NFT fighter
    uint256 private mintPrice = 0.01 * 1000000000000000000;

    // Mapping from bytes to base stats for creating fighters
    mapping(bytes => Stats) baseStats;
    // Mapping from bytes to trait adjustments by rarity
    mapping(bytes => TraitAdjustmentByRarity) rarityAdjustments;
    // Mapping from token ID to stats for a specific fighter
    mapping(uint256 => Stats) tokenToStats;

    // Initializes the contract and BaseStats
    constructor() ERC721("Punchathlon", "PUNCHR") {
        tokenId = 0;
        initBaseStats();
    }

    /*
     * Initializes the base stats for each fighter class and rarity adjustments for each rarity level.
     * These values are used to calculate the final stats for a fighter when it is created.
     */
    function initBaseStats() internal {
        // Initialize the base stats for each fighter class
        Stats memory jiuJitsu = Stats(80, 80, 20, 0, FighterClass.JiuJitsu, Rarities.Common);
        Stats memory kickBoxing = Stats(60, 60, 60, 0, FighterClass.KickBoxing, Rarities.Common);
        Stats memory judo = Stats(40, 60, 80, 0, FighterClass.Judo, Rarities.Common);
        Stats memory wrestling = Stats(20, 100, 60, 0, FighterClass.Wrestling, Rarities.Common);
        Stats memory muayThai = Stats(100, 40, 40, 0, FighterClass.MuayThai, Rarities.Common);

        // Store the base stats in the baseStats mapping
        baseStats[abi.encode(FighterClass.JiuJitsu)] = jiuJitsu;
        baseStats[abi.encode(FighterClass.KickBoxing)] = kickBoxing;
        baseStats[abi.encode(FighterClass.Judo)] = judo;
        baseStats[abi.encode(FighterClass.Wrestling)] = wrestling;
        baseStats[abi.encode(FighterClass.MuayThai)] = muayThai;

        // Initialize the rarity adjustments for each rarity level
        TraitAdjustmentByRarity memory common = TraitAdjustmentByRarity(-20, 0);
        TraitAdjustmentByRarity memory uncommon = TraitAdjustmentByRarity(-15, 5);
        TraitAdjustmentByRarity memory rare = TraitAdjustmentByRarity(-10, 10);
        TraitAdjustmentByRarity memory legendary = TraitAdjustmentByRarity(-5, 15);

        // Store the rarity adjustments in the rarityAdjustments mapping
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

    /*
     * @dev Creates a new NFT (non-fungible token) and assigns it to the msg.sender.
     * @param _class String representing the class of the NFT (e.g. "warrior", "archer", etc.)
     * @param _imageURI String containing the URI of an image representing the NFT
     * @param mintPrice Minimum amount of ether that must be sent with the transaction in order to create the NFT
     * @return The ID of the newly created NFT
     */
    function mint(string memory _class, string memory _imageURI) public payable {
        // Ensure that the maximum number of NFTs has not been reached
        require(tokenId < maxTokenIds, "Exceed maximum fighters supply");

        // Ensure that the correct amount of ether has been sent with the transaction
        require(msg.value >= mintPrice, "Ether sent is not correct");

        // Set the base stats for the NFT based on its class
        tokenToStats[tokenId] = getFighterClassBaseStats(_class);

        tokenToStats[tokenId].rarity = getRarity();

        // Assign the NFT to the msg.sender
        _safeMint(msg.sender, tokenId);

        // Set the URI of the NFT's image
        _setTokenURI(tokenId, _imageURI);

        // Increment the global NFT counter
        tokenId++;
    }

    /*
     * Returns the rarity value with some random input.
     *
     * @return The rarity value.
     */
    function getRarity() private view returns (Rarities) {
        uint256 timestampMod4 = block.timestamp % 4;
        if (timestampMod4 == 0) {
            return Rarities.Common;
        } else if (timestampMod4 == 1) {
            return Rarities.Uncommon;
        } else if (timestampMod4 == 2) {
            return Rarities.Rare;
        } else if (timestampMod4 == 3) {
            return Rarities.Legendary;
        } else {
            return Rarities.Common;
        }
    }

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

    /*
     * getFighterStats returns the stats for a given fighter token
     * @param tokenId The ID of the fighter token
     * @return The stats for the given token
     */
    function getFighterStats(uint256 tokenId) public returns (Stats memory) {
        return tokenToStats[tokenId];
    }

    /*
     * getTokenId returns the current token ID
     * @return The current token ID
     */
    function getTokenId() public view returns (uint256) {
        return tokenId;
    }

    /*
     * getMaxTokenIds returns the maximum number of tokens that can be created
     * @return The maximum number of tokens
     */
    function getMaxTokenIds() public view returns (uint256) {
        return maxTokenIds;
    }

    /*
     * getPrice returns the price of a single token
     * @return The price of a single token
     */
    function getPrice() public view returns (uint256) {
        return mintPrice;
    }
}
