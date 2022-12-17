//SPDX-License-Identifier: Unlicense
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

    struct Stats {
        uint8 strength;
        uint8 stamina;
        uint8 technique;
        uint8 victories;
    }

    mapping (bytes => Stats) baseStats;


    constructor() ERC721("Punchathlon", "PUNCHR") ERC721Enumerable() ERC721URIStorage() {
        initBaseStats();
    }

    function initBaseStats() internal {
        Stats memory jiuJitsu = Stats(80, 80, 20, 0);
        Stats memory kickBoxing = Stats(60, 60, 60, 0);
        Stats memory judo = Stats(40, 60, 80, 0);
        Stats memory wrestling = Stats(20, 100, 60, 0);
        Stats memory muayThai = Stats(100, 40, 40, 0);

        baseStats[abi.encode(FighterClass.JiuJitsu)] = jiuJitsu;
        baseStats[abi.encode(FighterClass.KickBoxing)] = kickBoxing;
        baseStats[abi.encode(FighterClass.Judo)] = judo;
        baseStats[abi.encode(FighterClass.Wrestling)] = wrestling;
        baseStats[abi.encode(FighterClass.MuayThai)] = muayThai;
    }

    function getFighterClassBaseStats(string memory fighterClassName) internal returns(Stats memory) {
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("JiuJitsu"))) return baseStats[abi.encode(FighterClass.JiuJitsu)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("KickBoxing"))) return baseStats[abi.encode(FighterClass.KickBoxing)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("Judo"))) return baseStats[abi.encode(FighterClass.Judo)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("Wrestling"))) return baseStats[abi.encode(FighterClass.Wrestling)];
        if (keccak256(bytes(fighterClassName)) == keccak256(bytes("MuayThai"))) return baseStats[abi.encode(FighterClass.MuayThai)];

        return Stats(0, 0, 0, 0);
    }

    function mint(string memory fighterClass, string memory tokenURI) external returns (uint256) {
        
        return 0;
    }


    // Overrides

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return "Not implemented yet!";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return ERC721.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        ERC721._beforeTokenTransfer(from, to, 1, batchSize);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        return ERC721._burn(tokenId);
    }
}
