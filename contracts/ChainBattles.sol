// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stats {
        uint256 level;
        uint256 hp;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => Stats) public tokenIdToStats;

    //track levels
    //track hp
    //track strength
    //track speed

    constructor() ERC721("Chain Battles", "CBTLS") {
    }

    function generateCharacter(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked( 
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<linearGradient id="grad" x1="1" x2="0" y1="1" y2="0">',
                '<stop offset="0%" stop-color="#00ccff"/>',
                '<stop offset="25%" stop-color="#00ccff"/>',
                '<stop offset="100%" stop-color="#ccffff"/>',
            '</linearGradient>',
            '<style>.base { fill: url(#grad); font-family: palatino; font-size: 13px; }</style>',
            '<style>.title { fill: url(#grad); font-family: palatino; font-size: 25px; font-weight: bold; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="title" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Level: ",getLevels(tokenId),'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',"HP: ",getHP(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',"Strength: ",getStrength(tokenId),'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',"Speed: ",getSpeed(tokenId),'</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            ));
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToStats[tokenId].level;
        return levels.toString();
    }

    function getHP(uint256 tokenId) public view returns (string memory) {
        uint256 HP = tokenIdToStats[tokenId].hp;
        return HP.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        uint256 strength = tokenIdToStats[tokenId].strength;
        return strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        uint256 speed = tokenIdToStats[tokenId].speed;
        return speed.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function random(uint number) private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToStats[newItemId].level = 0;
        tokenIdToStats[newItemId].hp = random(100);
        tokenIdToStats[newItemId].strength = random(200) + 45;
        tokenIdToStats[newItemId].speed = random(225) + 35;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it!");
        uint256 currentLevel = tokenIdToStats[tokenId].level;
        tokenIdToStats[tokenId].level = currentLevel + 1;
        tokenIdToStats[tokenId].hp += 50;
        tokenIdToStats[tokenId].strength += 25;
        tokenIdToStats[tokenId].speed += 25;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

}   
