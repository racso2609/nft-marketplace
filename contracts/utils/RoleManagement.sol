pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleManagement is AccessControl {
    function becomeAdmin(address _user) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(DEFAULT_ADMIN_ROLE, _user);
    }

    function isAdmin(address _user) public view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _user);
    }
}
