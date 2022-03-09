pragma solidity ^0.8.7;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./ERC1155/ERC1155.sol";
import "./utils/RoleManagement.sol";
import "./utils/TaxManagement.sol";

import "./utils/PriceConsumer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Marketplace is
    Initializable,
    RoleManagement,
    TaxManagement,
    PriceConsumerV3
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    Nft public erc1155;
    Counters.Counter private sellQuantity;
    IERC20 daiToken;
    IERC20 linkToken;

    struct Sale {
        uint256 tokenId;
        uint256 amount;
        uint256 priceUSD;
        uint256 duration;
        uint256 startTime;
        bool sold;
        bool cancelled;
        address owner;
    }
    modifier isPosibleToBuy(uint256 _saleId) {
        require(
            block.timestamp <
                sales[_saleId].startTime + sales[_saleId].duration,
            "Deadline reached!"
        );
        require(!sales[_saleId].sold, "Tokens solds!");
        require(!sales[_saleId].cancelled, "Sale cancelled!");

        _;
    }
    event Buy(uint256 _saleId, address buyer, address seller);
    event CancelSale(uint256 _saleId, address seller);
    event CreateSale(uint256 _saleId, address seller);

    /// @dev link saleId to an sell
    mapping(uint256 => Sale) public sales;

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
        priceFeedETH = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        priceFeedDAI = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );
        priceFeedLink = AggregatorV3Interface(
            0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c
        );

        daiToken = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        linkToken = IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA);
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

    /// @param _taxRate new tax rate selected to the admin
    /// @dev change admin tax rate

    function setTaxRate(uint256 _taxRate)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setTaxRate(_taxRate);
    }

    /// @param _recipient new witdraw address
    /// @dev change address recipient

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
        Sale memory newSale;
        newSale.tokenId = _tokenId;
        newSale.amount = _amount;
        newSale.priceUSD = _priceUSD.mul(10**18); //parse ether
        newSale.duration = _duration;
        newSale.startTime = block.timestamp;
        newSale.owner = msg.sender;
        sales[sellQuantity.current()] = newSale;

        sellQuantity.increment();
        emit CreateSale(sellQuantity.current() - 1, msg.sender);
        return sellQuantity.current() - 1;
    }

    /* @params _saleId identifier of the current sale */
    /* @dev cancel the sale */

    function cancelSale(uint256 _saleId) external {
        require(sales[_saleId].owner == msg.sender, "You are not the owner!");
        sales[_saleId].cancelled = true;
        emit CancelSale(_saleId, msg.sender);
    }

    /* @params _saleId identifier of the current sale */
    /* @dev the next 3 function work similar with different coin ETH,DAI and LINK */

    function buyEth(uint256 _saleId) external payable isPosibleToBuy(_saleId) {
        uint256 usdPrice = getLatestPriceEthToUsd();
        // 1 coin == getLatestPrice
        // ?      ==    _amount
        uint256 totalCoins = sales[_saleId].priceUSD.div(usdPrice);
        require(msg.value >= totalCoins, "Incorrect amount!");
        uint256 tokenId = sales[_saleId].tokenId;
        (, address ownerOfNft) = erc1155.nfts(tokenId);
        payable(ownerOfNft).call{value: totalCoins};
        if (msg.value > totalCoins)
            payable(msg.sender).call{value: msg.value - totalCoins};

        sales[_saleId].sold = true;
        emit Buy(_saleId, msg.sender, sales[_saleId].owner);
    }

    function buyDai(uint256 _saleId) external isPosibleToBuy(_saleId) {
        uint256 usdPrice = getLatestPriceDaiToUsd();
        // 1 coin == getLatestPrice
        // ?      ==    _amount
        uint256 totalCoins = sales[_saleId].priceUSD.div(usdPrice);
        uint256 tokenId = sales[_saleId].tokenId;
        (, address ownerOfNft) = erc1155.nfts(tokenId);
        daiToken.transferFrom(msg.sender, ownerOfNft, totalCoins);

        sales[_saleId].sold = true;
        emit Buy(_saleId, msg.sender, sales[_saleId].owner);
    }

    function buyLink(uint256 _saleId) external isPosibleToBuy(_saleId) {
        uint256 usdPrice = getLatestPriceLinkToUsd();
        // 1 coin == getLatestPrice
        // ?      ==    _amount
        uint256 totalCoins = sales[_saleId].priceUSD.div(usdPrice);
        uint256 tokenId = sales[_saleId].tokenId;
        (, address ownerOfNft) = erc1155.nfts(tokenId);
        linkToken.transferFrom(msg.sender, ownerOfNft, totalCoins);

        sales[_saleId].sold = true;
        emit Buy(_saleId, msg.sender, sales[_saleId].owner);
    }
}
