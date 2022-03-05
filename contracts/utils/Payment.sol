contract Payment {
    mapping(string => bool) avaliableMethods;

    modifier isValidMethod(string calldata _paymentType) {
        require(
            avaliableMethods[_paymentType],
            "This method is not avaliable!"
        );
        _;
    }

    function _updateAvaliablePayments(string[] memory _methods) internal {
        mapping(string => bool) newMethods;
        for (uint32 i = 0; i < _methods.length; i++) {
            newMethods[_methods[i]] = true;
        }
        avaliableMethods = newMethods;
    }

    function paymentWithEth() {}

    function _buy(uint256 tokenId, string calldata _paymentType)
        internal
        isValidMethod(_paymentType)
    {}
}
