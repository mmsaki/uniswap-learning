// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";

contract SwapV2 {
    address constant FACTORY_BASE = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
    address constant V2ROUTERV2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

    function getPair(address token1, address token2) external view returns (address) {
        return IUniswapV2Factory(FACTORY_BASE).getPair(token1, token2);
    }

    function createPair(address token1, address token2) external returns (address) {
        return IUniswapV2Factory(FACTORY_BASE).createPair(token1, token2);
    }
}
