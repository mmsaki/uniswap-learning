// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IUniswapV3Factory} from "v3-core/contracts/interfaces/IUniswapV3Factory.sol";

address constant UNISWAP_V3_FACTORY = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;

contract UniswapV3 {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address) {
        return IUniswapV3Factory(UNISWAP_V3_FACTORY).getPool(tokenA, tokenB, fee);
    }

    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address) {
        return IUniswapV3Factory(UNISWAP_V3_FACTORY).createPool(tokenA, tokenB, fee);
    }
}
