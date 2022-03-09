// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeedETH;
    AggregatorV3Interface internal priceFeedDAI;
    AggregatorV3Interface internal priceFeedLink;

    /**
     * @dev Returns the latest price ETH/USD
     */
    function getLatestPriceEthToUsd() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedETH.latestRoundData();
        return uint256(price); // return number with 8 decimal transform to 18 decimals
    }

    /**
     * @dev Returns the latest price DAI/USD
     */

    function getLatestPriceDaiToUsd() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedDAI.latestRoundData();
        return uint256(price);
    }

    /**
     * @dev Returns the latest price Link/USD
     */

    function getLatestPriceLinkToUsd() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedLink.latestRoundData();
        return uint256(price);
    }
}
