// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedDAI;
    AggregatorV3Interface internal priceFeedLink;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e    */
    /**
     * Network: Rinkeby
     * Aggregator: DAI/USD
     * Address: 0x74825DbC8BF76CC4e9494d0ecB210f676Efa001D
     */
    /**
     * Network: Rinkeby
     * Aggregator: Link/USD
     * Address: 0xd8bD0a1cB028a31AA859A21A3758685a95dE4623
     */
    constructor() {
        priceFeedETH = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        priceFeedDAI = AggregatorV3Interface(
            0x74825DbC8BF76CC4e9494d0ecB210f676Efa001D
        );
        priceFeedLink = AggregatorV3Interface(
            0xd8bD0a1cB028a31AA859A21A3758685a95dE4623
        );
    }

    /**
     * @dev Returns the latest price ETH/USD
     */
    function getLatestPriceEthToUsd() public view returns (uint256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedETH.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev Returns the latest price DAI/USD
     */

    function getLatestPriceDaiToUsd() public view returns (uint256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedDAI.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev Returns the latest price Link/USD
     */

    function getLatestPriceLinkToUsd() public view returns (uint256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeedLink.latestRoundData();
        return uint256(price);
    }
}
