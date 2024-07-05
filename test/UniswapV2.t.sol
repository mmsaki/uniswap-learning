// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {UniswapV2} from "../src/UniswapV2.sol";
import {MrBase} from "../src/Token.sol";

// Uniwasp: Base
address constant FACTORY = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
address constant ROUTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
address constant weth = 0x4200000000000000000000000000000000000006;
address constant usdc = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
address constant dai = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

event PairCreated(address, address, address, uint256);

contract SwapV2Test is Test {
    UniswapV2 swapV2;
    IUniswapV2Factory factory;
    IUniswapV2Router02 router;
    IERC20 token;
    address tokenA;
    address tokenB;
    IUniswapV2Pair pair;

    function setUp() public {
        vm.createSelectFork("base");
        swapV2 = new UniswapV2();
        token = new MrBase();
        factory = IUniswapV2Factory(FACTORY);
        router = IUniswapV2Router02(ROUTER);

        tokenA = weth;
        tokenB = address(token);
        pair = IUniswapV2Pair(factory.createPair(tokenA, tokenB));

        vm.label(FACTORY, "factory");
        vm.label(ROUTER, "router");
        vm.label(weth, "weth");
        vm.label(usdc, "usdc");
        vm.label(dai, "dai");
        vm.label(address(pair), "pair");

        vm.deal(address(this), 1e18);
    }

    function swapToken(address token0, address token1, uint256 amount) public returns (uint256) {}

    function addLiquidityETH(address token0, uint256 amount)
        public
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        (amountToken, amountETH, liquidity) =
            swapV2.addLiquidityETH{value: msg.value}(token0, amount, amount, msg.value, msg.sender, block.timestamp);
    }

    function removeLiquidityETH(address token0, uint256 liquidity)
        public
        returns (uint256 amount_token, uint256 amount_eth)
    {
        (amount_token, amount_eth) = swapV2.removeLiquidityETH(token0, liquidity);
    }

    function test_getPair() public view {
        assertEq(address(pair), swapV2.getPair(tokenA, tokenB));
    }

    function test_addLiquidityETH() public {
        uint256 amount = IERC20(tokenB).balanceOf(address(this)) / 1000;
        IERC20(tokenB).approve(address(swapV2), amount);
        uint256 value = 8e17;
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = this.addLiquidityETH{value: value}(tokenB, amount);
        assertEq(amountToken, amount);
        assertEq(amountETH, value);
        assertGt(liquidity, 0);
    }

    function test_removeLiquidityETH() external {
        uint256 amount = IERC20(tokenB).balanceOf(address(this)) / 1000;
        IERC20(tokenB).approve(address(swapV2), amount);
        uint256 value = 8e17;
        (uint256 amountToken, uint256 amountETH, uint256 liquidity) = this.addLiquidityETH{value: value}(tokenB, amount);

        pair.approve(address(swapV2), pair.balanceOf(address(this)));
        (uint256 amount_token, uint256 amount_eth) = this.removeLiquidityETH(tokenB, liquidity);

        assertGt(amount_token, amountToken * 99 / 100);
        assertGt(amount_eth, amountETH * 99 / 100);
    }

    // function test_swapPair() external {
    //     address pair = createPair(tokenA, tokenB);
    //     uint256 amountIn = 1e18;2
    //     swapToken(tokenA, tokenB, amountIn);
    //     assertGt(token.balanceOf(address(this)), 0);
    // }

    receive() external payable {}
}
