// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract UniswapV2 {
    address constant FACTORY = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
    address constant ROUTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address constant WETH = 0x4200000000000000000000000000000000000006;

    function getPair(address token1, address token2) external view returns (address) {
        return IUniswapV2Factory(FACTORY).getPair(token1, token2);
    }

    function createPair(address token1, address token2) external returns (address) {
        return IUniswapV2Factory(FACTORY).createPair(token1, token2);
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        IERC20(token).approve(ROUTER, amountTokenDesired);
        (amountToken, amountETH, liquidity) = IUniswapV2Router02(ROUTER).addLiquidityETH{value: msg.value}(
            token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline
        );
    }

    function removeLiquidityETH(address token0, uint256 liquidity)
        external
        returns (uint256 amount_token, uint256 amount_eth)
    {
        (address pair) = this.getPair(token0, WETH);
        IUniswapV2Pair(pair).transferFrom(msg.sender, address(this), IUniswapV2Pair(pair).balanceOf(msg.sender));
        IUniswapV2Pair(pair).approve(ROUTER, IUniswapV2Pair(pair).balanceOf(address(this)));
        (amount_token, amount_eth) =
            IUniswapV2Router02(ROUTER).removeLiquidityETH(token0, liquidity, 0, 0, msg.sender, block.timestamp);
    }
}
