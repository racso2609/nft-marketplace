contract Payment is PriceConsumerV3 {
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

    function getLatestPrice(string calldata _paymentType)
        public
        returns (int256)
    {
        if (_paymentType == "dai") {
            return getLatestPriceDaiToUsd();
        } else if (_paymentType == "link") {
            return getLatestPriceLinkToUsd();
        } else {
            return getLatestPriceEthToUsd();
        }
    }

    function _buy(
        uint256 _tokenId,
        string calldata _paymentType,
        uint256 _amount
    ) internal isValidMethod(_paymentType) {
        int256 usdPrice = getLatestPrice(_paymentType);
        // 1 coin == getLatestPrice
        // ?      ==    _amount
    }
}
