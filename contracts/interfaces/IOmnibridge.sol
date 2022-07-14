pragma solidity 0.7.5;

interface IOmnibridge {
    function relayTokens(
        address _token,
        address _receiver,
        uint256 _value
    ) external payable;

    /**
     * @dev Gets the flat fee in chain's native coin to be paid for message relay.
     * @return fee value.
     */
    function passMessageFlatFee() external view returns (uint256);
}
