// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/SwapCoins.sol";

contract SwapCoinsTest is Test, ISwapCoinsEvents {
    SwapCoins public c;

    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant USDC_WHALE_ADDRESS = 0xDa9CE944a37d218c3302F6B82a094844C6ECEb17;

    // address used for testing
    address private constant USER = address(1337);

    function setUp() public {
        c = new SwapCoins(USDC, USDT, ROUTER);
    }

    function testSwapUSDCtoUSDT() public {
        // 100 USDC (6 decimals)
        uint256 amountToSwap = 100_000_000;

        // Test case 1
        vm.startPrank(USER);
        // Make sure user's USDC balance is 0
        assertEq(IERC20(USDC).balanceOf(USER), 0);
        
        vm.expectRevert(bytes("SC: not enough swap amount"));
        c.swapUSDCtoUSDT(amountToSwap);

        vm.stopPrank();

        // Test case 2

        // Impersonate USDC whale address
        vm.startPrank(USDC_WHALE_ADDRESS);

        // it should revert as we didn't approve yet
        vm.expectRevert(bytes("ERC20: transfer amount exceeds allowance"));
        c.swapUSDCtoUSDT(amountToSwap);

        vm.stopPrank();

        // Test case 3
        vm.startPrank(USDC_WHALE_ADDRESS);

        uint256 amountUSDTBefore = IERC20(USDT).balanceOf(USDC_WHALE_ADDRESS);
        
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = USDT;

        uint256 amountUSDTSwapped = IUniswapV2Router02(ROUTER).getAmountsOut(amountToSwap, path)[1];

        IERC20(USDC).approve(address(c), amountToSwap);
        vm.expectEmit(true, true, true, true);
        emit Swapped(amountToSwap, amountUSDTSwapped);
        c.swapUSDCtoUSDT(amountToSwap);

        uint256 amountUSDTAfter = IERC20(USDT).balanceOf(USDC_WHALE_ADDRESS);
        assertEq(amountUSDTBefore + amountUSDTSwapped, amountUSDTAfter);

        vm.stopPrank();

    }
}