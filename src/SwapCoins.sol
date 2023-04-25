// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap-v2-periphery/interfaces/IUniswapV2Router02.sol";

import "./interfaces/ISwapCoins.sol";

contract SwapCoins is ISwapCoinsEvents {
    using SafeERC20 for IERC20;

    IERC20 usdc;
    IERC20 usdt;

    IUniswapV2Router02 router;

    constructor(address _usdc, address _usdt, address _router) {
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
        router = IUniswapV2Router02(_router);
    }
    
    function swapUSDCtoUSDT(uint256 amountUSDC) external {
        uint256 userBalance = usdc.balanceOf(msg.sender);
        require(userBalance >= amountUSDC, "SC: not enough swap amount");

        usdc.safeTransferFrom(msg.sender, address(this), amountUSDC);

        usdc.safeApprove(address(router), amountUSDC);

        address[] memory path = new address[](2);
        path[0] = address(usdc);
        path[1] = address(usdt);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountUSDC,
            // amountOutMin could be calculated using getAmountsOut() function but that
            // just increases the gas fee and not necessary to use here.
            1,
            path,
            address(this),
            type(uint256).max
        );

        usdt.safeTransfer(msg.sender, amounts[1]);

        emit Swapped(amountUSDC, amounts[1]);
    }
}