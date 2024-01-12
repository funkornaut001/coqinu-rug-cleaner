// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155 is ERC1155 {
    uint256 private _tokenIdCounter;

    constructor() ERC1155("https://token-cdn-domain/{id}.json") {}

    function mint(address account, uint256 amount) public {
        _mint(account, _tokenIdCounter, amount, "");
        _tokenIdCounter++;
    }
}
