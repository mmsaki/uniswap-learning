// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
pragma abicoder v2;

import {IWETH, SwapRouter02} from "./interface.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "./TestSetup.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/LowGasSafeMath.sol";
import "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/// @title Flash contract implementation
/// @notice An example contract using the Uniswap V3 flash function
contract PairFlash is TestSetup {
    SwapRouter02 swapRouter = SwapRouter02(payable(0x2626664c2603336E57B271c5C0b26F421741e481));
    IUniswapV3Factory factory_v3 = IUniswapV3Factory(0x33128a8fC17869897dcE68Ed026d694621f6FDfD);
    address _usdc = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    using LowGasSafeMath for uint256;
    using LowGasSafeMath for int256;

    function testFuzz_ARB() public {
        vm.createSelectFork("base");
        vm.label(address(swapRouter), "swapRouter02");

        FlashParams memory params = FlashParams({
            token0: address(weth),
            token1: _usdc,
            fee1: 500,
            amount0: 2.7 ether,
            amount1: 7600e6,
            fee2: 100,
            fee3: 1000
        });
        this.initFlash(params);
    }

    /// @param fee0 The fee from calling flash for token0
    /// @param fee1 The fee from calling flash for token1
    /// @param data The data needed in the callback passed as FlashCallbackData from `initFlash`
    /// @notice implements the callback called from flash
    /// @dev fails if the flash is not profitable, meaning the amountOut from the flash is less than the amount borrowed
    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external {
        console.log("1.2.0 uniswapV3FlashCallback");
        console.log("1.2.0 uniswapV3FlashCallback usdc", IERC20(_usdc).balanceOf(address(this)));
        console.log("1.2.0 uniswapV3FlashCallback weth", weth.balanceOf(address(this)));
        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));

        address token0 = decoded.poolKey.token0;
        address token1 = decoded.poolKey.token1;

        TransferHelper.safeApprove(token0, address(swapRouter), decoded.amount0);
        TransferHelper.safeApprove(token1, address(swapRouter), decoded.amount1);

        // profitable check
        // exactInputSingle will fail if this amount not met
        uint256 amount1Min = LowGasSafeMath.add(decoded.amount1, fee1);
        uint256 amount0Min = LowGasSafeMath.add(decoded.amount0, fee0);

        // call exactInputSingle for swapping token1 for token0 in pool w/fee2
        uint256 amountOut0 = swapRouter.exactInputSingle(
            SwapRouter02.ExactInputSingleParams({
                tokenIn: token1,
                tokenOut: token0,
                fee: decoded.poolFee2,
                recipient: address(this),
                amountIn: decoded.amount1,
                amountOutMinimum: amount0Min,
                sqrtPriceLimitX96: 0
            })
        );

        // call exactInputSingle for swapping token0 for token 1 in pool w/fee3
        uint256 amountOut1 = swapRouter.exactInputSingle(
            SwapRouter02.ExactInputSingleParams({
                tokenIn: token0,
                tokenOut: token1,
                fee: decoded.poolFee3,
                recipient: address(this),
                amountIn: decoded.amount0,
                amountOutMinimum: amount1Min,
                sqrtPriceLimitX96: 0
            })
        );

        // end up with amountOut0 of token0 from first swap and amountOut1 of token1 from second swap
        uint256 amount0Owed = LowGasSafeMath.add(decoded.amount0, fee0);
        uint256 amount1Owed = LowGasSafeMath.add(decoded.amount1, fee1);

        TransferHelper.safeApprove(token0, address(this), amount0Owed);
        TransferHelper.safeApprove(token1, address(this), amount1Owed);

        if (amount0Owed > 0) pay(token0, address(this), msg.sender, amount0Owed);
        if (amount1Owed > 0) pay(token1, address(this), msg.sender, amount1Owed);

        // if profitable pay profits to payer
        if (amountOut0 > amount0Owed) {
            uint256 profit0 = LowGasSafeMath.sub(amountOut0, amount0Owed);

            TransferHelper.safeApprove(token0, address(this), profit0);
            pay(token0, address(this), decoded.payer, profit0);
        }
        if (amountOut1 > amount1Owed) {
            uint256 profit1 = LowGasSafeMath.sub(amountOut1, amount1Owed);
            TransferHelper.safeApprove(token0, address(this), profit1);
            pay(token1, address(this), decoded.payer, profit1);
        }
    }

    //fee1 is the fee of the pool from the initial borrow
    //fee2 is the fee of the first pool to arb from
    //fee3 is the fee of the second pool to arb from
    struct FlashParams {
        address token0;
        address token1;
        uint24 fee1;
        uint256 amount0;
        uint256 amount1;
        uint24 fee2;
        uint24 fee3;
    }
    // fee2 and fee3 are the two other fees associated with the two other pools of token0 and token1

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address payer;
        PoolAddress.PoolKey poolKey;
        uint24 poolFee2;
        uint24 poolFee3;
    }

    /// @param params The parameters necessary for flash and the callback, passed in as FlashParams
    /// @notice Calls the pools flash function with data needed in `uniswapV3FlashCallback`
    function initFlash(FlashParams memory params) external {
        console.log("1.0 initFlash()");
        PoolAddress.PoolKey memory poolKey =
            PoolAddress.PoolKey({token0: params.token0, token1: params.token1, fee: params.fee1});

        IUniswapV3Pool pool = IUniswapV3Pool(PoolAddress.computeAddress(address(factory_v3), poolKey));
        vm.label(address(pool), "pool");
        console.log("1.1 poolKey", address(pool));

        // recipient of borrowed amounts
        // amount of token0 requested to borrow
        // amount of token1 requested to borrow
        // need amount 0 and amount1 in callback to pay back pool
        // recipient of flash should be THIS contract
        pool.flash(
            address(this),
            params.amount0,
            params.amount1,
            abi.encode(
                FlashCallbackData({
                    amount0: params.amount0,
                    amount1: params.amount1,
                    payer: msg.sender,
                    poolKey: poolKey,
                    poolFee2: params.fee2,
                    poolFee3: params.fee3
                })
            )
        );
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(address token, address payer, address recipient, uint256 value) internal {
        if (token == address(weth) && address(this).balance >= value) {
            // pay with WETH9
            IWETH(address(weth)).deposit{value: value}(); // wrap only what is needed to pay
            IWETH(address(weth)).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            // pull payment
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
}
