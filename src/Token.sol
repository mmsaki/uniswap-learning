// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MrBase is ERC20, ERC20Permit {
    constructor() ERC20("MR BASE", unicode"BASE") ERC20Permit("BASED") {
        _mint(msg.sender, 1000000000000000000 * 10 ** decimals());
    }
}
