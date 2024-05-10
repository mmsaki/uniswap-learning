// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IFactory} from "";
import {SwapV2} from "../src/SwapV2.sol";

address constant FACTORY_BASE = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
address constant V2ROUTERV2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

contract SwapV2Test is Test {
    SwapV2 public swapV2;

    function setUp() public {
        swapV2 = new SwapV2();
    }

    function testFactory() public {}
}
