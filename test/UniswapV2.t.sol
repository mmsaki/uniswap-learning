// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {UniswapV2} from "../src/UniswapV2.sol";
import {MrBase} from "../src/Token.sol";

// Uniwasp: Base
address constant FACTORY_BASE = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
address constant V2ROUTERV2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

// Tokens: Base
address constant weth = 0x4200000000000000000000000000000000000006;
address constant usdc = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
address constant dai = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

contract SwapV2Test is Test {
    UniswapV2 public swapV2;
    IUniswapV2Factory public factory;
    IERC20 public token;

    function setUp() public {
        swapV2 = new UniswapV2();
        token = new MrBase();
        factory = IUniswapV2Factory(FACTORY_BASE);
    }

    function test_getPair() public view {
        address tokenA = weth;
        address tokenB = usdc;
        address pair = swapV2.getPair(tokenA, tokenB);
        assertEq(factory.getPair(tokenA, tokenB), pair);
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        if (token0 == tokenA) {
            assertEq(token0, tokenA);
            assertEq(token1, tokenB);
        } else {
            assertEq(token1, tokenA);
            assertEq(token0, tokenB);
        }
    }

    function test_createPair() external {
        address tokenA = weth;
        address tokenB = address(token);

        address pair = swapV2.createPair(tokenA, tokenB);
        address pair_exists = factory.getPair(tokenA, tokenB);
        assertEq(pair, pair_exists);
    }
}
