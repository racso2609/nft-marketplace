import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./ERC721/ERC721.sol";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract Marketplace is Initializable, AccessControlUpgradeable {
    ERC721 public erc721;
    uint256 public taxRate;
    address public recipient;

    /// @param _erc721 address of the erc721 contract already initialized
    /// @dev initialize marketplace contract
    function initialize(
        ERC721 _erc721,
        uint256 _taxRate,
        address _recipient
    ) external initializer {
        erc721 = _erc721;
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        taxRate = _taxRate;
        recipient = _recipient;
    }

    /// @param _erc721 address of the erc721 contract already initialized
    /// @dev change the erc721 contract only owner

    function reinitialize(ERC721 _erc721)
        external
        onlyInitializing
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        erc721 = _erc721;
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
