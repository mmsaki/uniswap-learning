// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ISwapRouter} from "v3-periphery/interfaces/ISwapRouter.sol";
import {IUniswapV3Factory} from "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {UniswapV3} from "../src/UniswapV3.sol";

import {MrBase} from "../src/Token.sol";

// Contracts: Base
address constant SWAP_ROUTER_02 = 0x2626664c2603336E57B271c5C0b26F421741e481;
address constant UNISWAP_V3_FACTORY = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
address constant QUOTER_O2 = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
address constant UNIVERSAL_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;

// Tokens: Base
address constant WETH = 0x4200000000000000000000000000000000000006;
address constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
address constant DAI = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

uint24 constant FEE_100 = 100;
uint24 constant FEE_500 = 500;
uint24 constant FEE_3000 = 3000;
uint24 constant FEE_10000 = 10000;

contract TestSwapV3 is Test {
    UniswapV3 swapV3;
    MrBase token;
    address tokenA = WETH;
    address tokenB = DAI;
    uint24 fee = FEE_3000;

    function setUp() public {
        vm.createSelectFork("base");
        swapV3 = new UniswapV3();
        token = new MrBase();
    }

    function test_getPool() public view {
        address pool = swapV3.getPool(tokenA, tokenB, fee);
        address pool_exists = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(tokenA, tokenB, fee);
        assertEq(pool, pool_exists);
    }

    function test_createPool() public {
        tokenB = address(token);

        // Test createPool
        address pool = swapV3.createPool(tokenA, tokenB, fee);
        vm.expectRevert();
        IUniswapV3Factory(UNISWAP_V3_FACTORY).createPool(tokenA, tokenB, fee);
        address pool_exists = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(tokenA, tokenB, fee);
        assertEq(pool, pool_exists);

        // Test different fee pool
        fee = FEE_500;
        pool = swapV3.createPool(tokenA, tokenB, fee);
        assertNotEq(pool, pool_exists);
        pool_exists = IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(tokenA, tokenB, fee);
        assertEq(pool, pool_exists);
    }
}
