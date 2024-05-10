// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";
import {SwapV3} from "../src/SwapV3.sol";

// Base
address constant swapRouter02 = 0x2626664c2603336E57B271c5C0b26F421741e481;
address constant uniswapV3Factory = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
address constant quoterV2 = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
address constant universalRouter = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

contract TestSwapV3 is Test {
    function setUp() public {
        swapV3 = new SwapV3();
    }
}
