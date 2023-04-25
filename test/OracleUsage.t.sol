// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/OracleUsage.sol";

contract MockPriceFeed is IChainlinkPriceFeed {
    function latestRoundData() public view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        roundId = 0;
        answer = -1 ether;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;
    }
}

contract OracleUsageTest is Test {
    OracleUsage public c;
    MockPriceFeed public mockPriceFeed;

    address private constant priceFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function setUp() public {
        c = new OracleUsage(priceFeed);
        mockPriceFeed = new MockPriceFeed();
    }

    function testConvertETHtoUSD() public {
        // Should work as expected
        (, int price,,,) = IChainlinkPriceFeed(priceFeed).latestRoundData();
        uint256 amountToConvert = 3 ether;

        assertEq(c.convertETHtoUSD(amountToConvert), uint256(price) * amountToConvert / 1 ether);

        // Should revert if the price feed accidently returns negative price
        c.setNewOracle(address(mockPriceFeed));

        vm.expectRevert(InvalidPrice.selector);
        c.convertETHtoUSD(amountToConvert); 
    }
}
