// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedDAI;
    AggregatorV3Interface internal priceFeedLink;

    /**
     * Network: Main
     * Aggregator: ETH/USD
     * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419     */
    /**
     * Network: Main
     * Aggregator: DAI/USD
     * Address: 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
     */
    /**
     * Network: Main
     * Aggregator: Link/USD
     * Address: 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c
     */
    constructor() {
        priceFeedETH = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        priceFeedDAI = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );
        priceFeedLink = AggregatorV3Interface(
            0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c
        );
    }

    /**
     * @dev Returns the latest price ETH/USD
     */
    function getLatestPriceEthToUsd() public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedETH.latestRoundData();
        return price;
    }

    /**
     * @dev Returns the latest price DAI/USD
     */

    function getLatestPriceDaiToUsd() public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedDAI.latestRoundData();
        return price;
    }

    /**
     * @dev Returns the latest price Link/USD
     */

    function getLatestPriceLinkToUsd() public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedLink.latestRoundData();
        return price;
    }
}
