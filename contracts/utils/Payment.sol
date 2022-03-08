pragma solidity ^0.8.7;
import "./PriceConsumer.sol";
import "../ERC20/interfaces/DaiToken.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Payment is PriceConsumerV3 {
    DaiToken daiToken;

    constructor() {
        daiToken = DaiToken(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }
}
