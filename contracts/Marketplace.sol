pragma solidity ^0.8.7;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./ERC1155/ERC1155.sol";
import "./utils/RoleManagement.sol";
import "./utils/TaxManagement.sol";
import "./utils/Payment.sol";

contract Marketplace is Initializable, RoleManagement, TaxManagement, Payment {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Nft public erc1155;
    Counters.Counter private sellQuantity;

    struct Sell {
        uint256 tokenId;
        uint256 amount;
        uint256 priceUSD;
        uint256 duration;
        uint256 startTime;
        bool sold;
        bool cancelled;
    }
    modifier isPosibleToBuy(uint256 _sellId) {
        require(
            block.timestamp <
                sells[_sellId].startTime + sells[_sellId].duration,
            "Deadline reached!"
        );
        require(!sells[_sellId].sold, "Tokens solds!");

        _;
    }

    /// @dev link sellId to an sell
    mapping(uint256 => Sell) public sells;

    /// @param _erc1155 address of the erc1155 contract already initialized
    /// @dev initialize marketplace contract
    function initialize(
        Nft _erc1155,
        uint256 _taxRate,
        address _recipient
    ) external initializer {
        erc1155 = _erc1155;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setTaxRate(_taxRate);
        _setRecipient(_recipient);
    }

    /// @param _erc1155 address of the erc1155 contract already initialized
    /// @dev change the erc721 contract only owner

    function reinitialize(Nft _erc1155)
        external
        onlyInitializing
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        erc1155 = _erc1155;
    }

    function setTaxRate(uint256 _taxRate)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setTaxRate(_taxRate);
    }

    function setRecipient(address _recipient)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setRecipient(_recipient);
    }

    /// @dev put nfts on sale
    function unlockForSale(
        uint256 _tokenId,
        uint256 _amount,
        uint256 _priceUSD,
        uint256 _duration
    ) external returns (uint256) {
        require(_amount > 0, "You cant sell 0 tokens!");
        require(
            erc1155.balanceOf(msg.sender, _tokenId) >= _amount,
            "You dont have enought tokens!"
        );
        Sell memory newSell;
        newSell.tokenId = _tokenId;
        newSell.amount = _amount;
        newSell.priceUSD = _priceUSD;
        newSell.duration = _duration;
        newSell.startTime = block.timestamp;
        sells[sellQuantity.current()] = newSell;

        sellQuantity.increment();
        return sellQuantity.current() - 1;
    }

    function buyEth(uint256 _sellId) external payable isPosibleToBuy(_sellId) {
        uint256 usdPrice = getLatestPriceEthToUsd();
        // 1 coin == getLatestPrice
        // ?      ==    _amount
        uint256 totalCoins = usdPrice.div(sells[_sellId].amount);

        uint256 tokenId = sells[_sellId].tokenId;
        (string memory tokenURI, address ownerOfNft) = erc1155.nfts(tokenId);
        require(msg.value >= totalCoins, "Incorrect amount!");
        payable(ownerOfNft).call{value: totalCoins}("");
        if (msg.value > totalCoins)
            payable(msg.sender).call{value: msg.value - totalCoins}("");

        sells[_sellId].sold = true;
    }

    function buyDai(uint256 _sellId) external isPosibleToBuy(_sellId) {
        uint256 usdPrice = getLatestPriceDaiToUsd();
        // 1 coin == getLatestPrice
        // ?      ==    _amount
        uint256 totalCoins = usdPrice.div(sells[_sellId].amount);
        uint256 tokenId = sells[_sellId].tokenId;
        (string memory tokenURI, address ownerOfNft) = erc1155.nfts(tokenId);
        require(
            daiToken.allowance(msg.sender, address(this)) >= totalCoins,
            "Allowance needed!"
        );
        daiToken.transferFrom(msg.sender, ownerOfNft, totalCoins);

        sells[_sellId].sold = true;
    }
}
