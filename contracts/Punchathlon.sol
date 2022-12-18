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
        uint8 low;
        uint8 high;
    }

    struct Match {
        uint256 tokenId1;
        uint256 tokenId2;
        uint256 outcome;
    }

    uint256 matchCounter = 0;
    uint8 maxMatches = 5;
    mapping (uint8 => Match) rooms;
    mapping (uint256 => Match) public matches;

    // The current token ID for creating new fighters
    uint256 private tokenId = 0;
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
        TraitAdjustmentByRarity memory common = TraitAdjustmentByRarity(0, 20);
        TraitAdjustmentByRarity memory uncommon = TraitAdjustmentByRarity(5, 25);
        TraitAdjustmentByRarity memory rare = TraitAdjustmentByRarity(10, 30);
        TraitAdjustmentByRarity memory legendary = TraitAdjustmentByRarity(15, 35);

        // Store the rarity adjustments in the rarityAdjustments mapping
        rarityAdjustments[abi.encode(Rarities.Common)] = common;
        rarityAdjustments[abi.encode(Rarities.Uncommon)] = uncommon;
        rarityAdjustments[abi.encode(Rarities.Rare)] = rare;
        rarityAdjustments[abi.encode(Rarities.Legendary)] = legendary;
    }

    function getFighterClassBaseStats(string memory fighterClassName) internal view returns (Stats memory) {
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

    function getAdjustmentByRarity(string memory rarity) internal view returns (TraitAdjustmentByRarity memory) {
        if (keccak256(bytes(rarity)) == keccak256(bytes("Common"))) return rarityAdjustments[abi.encode(Rarities.Common)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Uncommon")))
            return rarityAdjustments[abi.encode(Rarities.Uncommon)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Rare"))) return rarityAdjustments[abi.encode(Rarities.Rare)];
        if (keccak256(bytes(rarity)) == keccak256(bytes("Legendary")))
            return rarityAdjustments[abi.encode(Rarities.Legendary)];

        return TraitAdjustmentByRarity(0, 0);
    }

    function getAdjustmentByRarity(Rarities rarity) internal view returns (TraitAdjustmentByRarity memory) {
        if (rarity == Rarities.Common) return rarityAdjustments[abi.encode(Rarities.Common)];
        if (rarity == Rarities.Uncommon) return rarityAdjustments[abi.encode(Rarities.Uncommon)];
        if (rarity == Rarities.Rare) return rarityAdjustments[abi.encode(Rarities.Rare)];
        if (rarity == Rarities.Legendary) return rarityAdjustments[abi.encode(Rarities.Legendary)];

        return TraitAdjustmentByRarity(0, 0);
    }

    /*
     * @dev Creates a new NFT (non-fungible token) and assigns it to the msg.sender.
     * @param _class String representing the fighting style of the NFT fighter
     * @param _imageURI String containing the URI of an image representing the NFT
     * @param mintPrice Minimum amount of ether that must be sent with the transaction in order to create the NFT
     * @return The ID of the newly created NFT
     */
    function mint(string memory _class, string memory _imageURI) public payable {
        // Increment the global NFT counter
        tokenId++;
        
        // Ensure that the maximum number of NFTs has not been reached
        require(tokenId <= maxTokenIds, "Exceed maximum fighters supply");

        // Ensure that the correct amount of ether has been sent with the transaction
        require(msg.value >= mintPrice, "Ether sent is not correct");

        // Set the base stats for the NFT based on its class
        tokenToStats[tokenId] = getFighterClassBaseStats(_class);

        // adjust base stats by rarity
        tokenToStats[tokenId].rarity = getRarity();
        uint8 randNumber = uint8(block.timestamp % 20);
        tokenToStats[tokenId].strength =
            tokenToStats[tokenId].strength +
            getAdjustmentByRarity(tokenToStats[tokenId].rarity).low +
            randNumber;
        tokenToStats[tokenId].stamina =
            tokenToStats[tokenId].stamina +
            getAdjustmentByRarity(tokenToStats[tokenId].rarity).low +
            randNumber;
        tokenToStats[tokenId].technique =
            tokenToStats[tokenId].technique +
            getAdjustmentByRarity(tokenToStats[tokenId].rarity).low +
            randNumber;

        // Assign the NFT to the msg.sender
        _safeMint(msg.sender, tokenId);

        // Set the URI of the NFT's image
        _setTokenURI(tokenId, _imageURI);
    }

    function fight(uint256 _fighter1, uint256 _fighter2) private view returns (uint256) {
        uint8 fighter1Sum = tokenToStats[_fighter1].strength +
            tokenToStats[_fighter1].stamina +
            tokenToStats[_fighter1].technique +
            calcFightAdv(_fighter1, _fighter2);
        uint8 fighter2Sum = tokenToStats[_fighter2].strength +
            tokenToStats[_fighter2].stamina +
            tokenToStats[_fighter2].technique +
            calcFightAdv(_fighter2, _fighter1);

        if (fighter1Sum >= fighter2Sum) return _fighter1;
        else return _fighter2;
    }

    function calcFightAdv(uint256 _fighter1, uint256 _fighter2) private view returns (uint8) {
        if (
            tokenToStats[_fighter1].fightStyle == FighterClass.JiuJitsu &&
            (tokenToStats[_fighter2].fightStyle == FighterClass.Wrestling ||
                tokenToStats[_fighter2].fightStyle == FighterClass.MuayThai)
        ) {
            return 15;
        } else if (
            tokenToStats[_fighter1].fightStyle == FighterClass.KickBoxing &&
            (tokenToStats[_fighter2].fightStyle == FighterClass.JiuJitsu ||
                tokenToStats[_fighter2].fightStyle == FighterClass.MuayThai)
        ) {
            return 15;
        } else if (
            tokenToStats[_fighter1].fightStyle == FighterClass.Judo &&
            (tokenToStats[_fighter2].fightStyle == FighterClass.JiuJitsu ||
                tokenToStats[_fighter2].fightStyle == FighterClass.KickBoxing)
        ) {
            return 15;
        } else if (
            tokenToStats[_fighter1].fightStyle == FighterClass.Wrestling &&
            (tokenToStats[_fighter2].fightStyle == FighterClass.KickBoxing ||
                tokenToStats[_fighter2].fightStyle == FighterClass.Judo)
        ) {
            return 15;
        } else if (
            tokenToStats[_fighter1].fightStyle == FighterClass.MuayThai &&
            (tokenToStats[_fighter2].fightStyle == FighterClass.Judo ||
                tokenToStats[_fighter2].fightStyle == FighterClass.Wrestling)
        ) {
            return 15;
        }
        return 0;
    }

    function joinRoom(uint8 roomNumber, uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender);
        require(roomNumber < maxMatches);

        if (rooms[roomNumber].tokenId1 == 0) {
            rooms[roomNumber].tokenId1 = _tokenId;
            return;
        }

        if (rooms[roomNumber].tokenId2 == 0) {
            if (rooms[roomNumber].tokenId1 == _tokenId) {
                revert("You are joined in this room already.");
            }
            rooms[roomNumber].tokenId2 = _tokenId;
        } else {
            revert("Room is full!");
        }

        uint256 outcome = fight(rooms[roomNumber].tokenId1, rooms[roomNumber].tokenId2);
        rooms[roomNumber].outcome = outcome;
        matchCounter++;
        matches[matchCounter] = rooms[roomNumber];

        rooms[roomNumber] = Match(0, 0, 0);
    }

    /*
     * Returns the rarity value with some random input.
     *
     * @return The rarity value.
     */
    function getRarity() private view returns (Rarities) {
        uint256 timestampMod10 = block.timestamp % 100;
        if (timestampMod10 <= 50) {
            return Rarities.Common;
        } else if (timestampMod10 > 50 && timestampMod10 <= 85) {
            return Rarities.Uncommon;
        } else if (timestampMod10 > 85 && timestampMod10 <= 95) {
            return Rarities.Rare;
        } else {
            return Rarities.Legendary;
        }
    }

    function tokenURI(uint256 _tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(_tokenId);
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

    function _burn(uint256 _tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        return ERC721._burn(_tokenId);
    }

    /*
     * getFighterStats returns the stats for a given fighter token
     * @param tokenId The ID of the fighter token
     * @return The stats for the given token
     */
    function getFighterStats(uint256 _tokenId) public view returns (Stats memory) {
        return tokenToStats[_tokenId];
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
