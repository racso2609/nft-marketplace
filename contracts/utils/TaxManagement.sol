pragma solidity ^0.8.7;

contract TaxManagement {
    uint256 public taxRate;
    address public recipient;

    function _setRecipient(address _recipient) internal {
        recipient = _recipient;
    }

    function _setTaxRate(uint256 _taxRate) internal {
        taxRate = _taxRate;
    }
}
