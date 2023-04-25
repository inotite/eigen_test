// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;




error InvalidPrice();
// Could use chainlink contracts using foundry



interface IChainlinkPriceFeed {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}



interface IOracleUsageContractEvents {
    event OracleUpdated(address indexed oracle);
}

contract OracleUsage is IOracleUsageContractEvents {
    IChainlinkPriceFeed public oracle;

    address public admin;

    modifier onlyOwner {
        require(msg.sender == admin, 'OUC: invalid caller');
        _;
    }

    /// @dev price feed address will be passed when the contract is being created.
    /// on mainnet, ETH/USD price feed address is 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    constructor(address _oracle) {
        admin = msg.sender;

        setNewOracle(_oracle);
    }

    /// @dev ETH/USD pair has 8 decimals so the returned value has 8 decimals
    function convertETHtoUSD(uint256 ethAmount) public view returns (uint256) {
        (, int price,,,) = oracle.latestRoundData();

        if (price < 0) {
            revert InvalidPrice();
        }

        return uint256(price) * ethAmount / 1 ether;
    }

    function setNewOracle(address _oracle) public onlyOwner {
        oracle = IChainlinkPriceFeed(_oracle);

        emit OracleUpdated(_oracle);
    }
}
