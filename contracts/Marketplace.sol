import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ERC1155/ERC1155.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Marketplace is Initializable, AccessControlUpgradeable {
    Nft public erc1155;
    uint256 public taxRate;
    address public recipient;

    /// @param _erc1155 address of the erc1155 contract already initialized
    /// @dev initialize marketplace contract
    function initialize(
        Nft _erc1155,
        uint256 _taxRate,
        address _recipient
    ) external initializer {
        erc1155 = _erc1155;
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        taxRate = _taxRate;
        recipient = _recipient;
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

    function becomeAdmin(address _user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _user);
    }

    function isAdmin(address _user) public returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _user);
    }

    function setTaxRate(uint256 _taxRate)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        taxRate = _taxRate;
    }

    function setRecipient(address _recipient)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        recipient = _recipient;
    }
}
