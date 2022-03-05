import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ERC1155/ERC1155.sol";
import "./utils/RoleManagement.sol";
import "./utils/TaxManagement.sol";

contract Marketplace is Initializable, RoleManagement, TaxManagement {
    Nft public erc1155;

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
}
