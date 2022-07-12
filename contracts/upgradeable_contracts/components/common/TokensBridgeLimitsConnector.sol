pragma solidity 0.7.5;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../../upgradeability/EternalStorage.sol";
import "../../Ownable.sol";
import "./TokensBridgeLimits.sol";

/**
 * @title TokensBridgeLimitsConnector
 * @dev Functionality for keeping track of bridging limits for multiple tokens.
 */
contract TokensBridgeLimitsConnector is EternalStorage, Ownable {
    bytes32 internal constant TOKENS_BRIDGE_LIMITS_CONTRACT = 0x02063f9c538c8b4b8fa72d623161ceb67dfb9be2cc4f569c0184bc92a81683d8; // keccak256(abi.encodePacked("tokensBridgeLimitsContract"))

    /**
     * @dev Sets amount of gas to be gifted to the destination account if its balance is 0. Only the owner can call this method.
     * @param _contract free gas amount.
     */
    function setTokensBridgeLimitsContract(TokensBridgeLimits _contract) external onlyOwner {
        _setTokensBridgeLimitsContract(_contract);
    }

    /**
     * @dev Sets amount of gas to be gifted to the destination account if its balance is 0. Internal.
     * @param _contract free gas amount.
     */
    function _setTokensBridgeLimitsContract(TokensBridgeLimits _contract) internal {
        addressStorage[TOKENS_BRIDGE_LIMITS_CONTRACT] = address(_contract);
    }

    /**
     * @dev Gets amount of gas to be gifted to the destination account if its balance is 0.
     * @return _gas value.
     */
    function tokensBridgeLimitsContract() public view virtual returns (TokensBridgeLimitsConnector) {
        return TokensBridgeLimitsConnector(addressStorage[TOKENS_BRIDGE_LIMITS_CONTRACT]);
    }

    /**
     * @dev Checks if specified token was already bridged at least once.
     * @param _token address of the token contract.
     * @return true, if token address is address(0) or token was already bridged.
     */
    function isTokenRegistered(address _token) public view returns (bool) {
        return tokensBridgeLimitsContract().isTokenRegistered(_token);
    }

    /**
     * @dev Retrieves the total spent amount for particular token during specific day.
     * @param _token address of the token contract.
     * @param _day day number for which spent amount if requested.
     * @return amount of tokens sent through the bridge to the other side.
     */
    function totalSpentPerDay(address _token, uint256 _day) public view returns (uint256) {
        return tokensBridgeLimitsContract().totalSpentPerDay(_token, _day);
    }

    /**
     * @dev Retrieves the total executed amount for particular token during specific day.
     * @param _token address of the token contract.
     * @param _day day number for which spent amount if requested.
     * @return amount of tokens received from the bridge from the other side.
     */
    function totalExecutedPerDay(address _token, uint256 _day) public view returns (uint256) {
        return tokensBridgeLimitsContract().totalExecutedPerDay(_token, _day);
    }

    /**
     * @dev Retrieves current daily limit for a particular token contract.
     * @param _token address of the token contract.
     * @return daily limit on tokens that can be sent through the bridge per day.
     */
    function dailyLimit(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().dailyLimit(_token);
    }

    /**
     * @dev Retrieves current execution daily limit for a particular token contract.
     * @param _token address of the token contract.
     * @return daily limit on tokens that can be received from the bridge on the other side per day.
     */
    function executionDailyLimit(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().executionDailyLimit(_token);
    }

    /**
     * @dev Retrieves current maximum amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return maximum amount on tokens that can be sent through the bridge in one transfer.
     */
    function maxPerTx(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().maxPerTx(_token);
    }

    /**
     * @dev Retrieves current maximum execution amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return maximum amount on tokens that can received from the bridge on the other side in one transaction.
     */
    function executionMaxPerTx(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().executionMaxPerTx(_token);
    }

    /**
     * @dev Retrieves current minimum amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return minimum amount on tokens that can be sent through the bridge in one transfer.
     */
    function minPerTx(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().minPerTx(_token);
    }

    /**
     * @dev Checks that bridged amount of tokens conforms to the configured limits.
     * @param _token address of the token contract.
     * @param _amount amount of bridge tokens.
     * @return true, if specified amount can be bridged.
     */
    function withinLimit(address _token, uint256 _amount) public view returns (bool) {
        return tokensBridgeLimitsContract().withinLimit(_token, _amount);
    }

    /**
     * @dev Checks that bridged amount of tokens conforms to the configured execution limits.
     * @param _token address of the token contract.
     * @param _amount amount of bridge tokens.
     * @return true, if specified amount can be processed and executed.
     */
    function withinExecutionLimit(address _token, uint256 _amount) public view returns (bool) {
        return tokensBridgeLimitsContract().withinExecutionLimit(_token, _amount);
    }

    /**
     * @dev Returns current day number.
     * @return day number.
     */
    function getCurrentDay() public view returns (uint256) {
        return tokensBridgeLimitsContract().getCurrentDay();
    }

    /**
     * @dev Updates daily limit for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the efault limit.
     * @param _dailyLimit daily allowed amount of bridged tokens, should be greater than maxPerTx.
     * 0 value is also allowed, will stop the bridge operations in outgoing direction.
     */
    function setDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        tokensBridgeLimitsContract().setDailyLimit(_token, _dailyLimit);
    }

    /**
     * @dev Updates execution daily limit for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _dailyLimit daily allowed amount of executed tokens, should be greater than executionMaxPerTx.
     * 0 value is also allowed, will stop the bridge operations in incoming direction.
     */
    function setExecutionDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        tokensBridgeLimitsContract().setExecutionDailyLimit(_token, _dailyLimit);
    }

    /**
     * @dev Updates execution maximum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _maxPerTx maximum amount of executed tokens per one transaction, should be less than executionDailyLimit.
     * 0 value is also allowed, will stop the bridge operations in incoming direction.
     */
    function setExecutionMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        tokensBridgeLimitsContract().setExecutionMaxPerTx(_token, _maxPerTx);
    }

    /**
     * @dev Updates maximum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _maxPerTx maximum amount of tokens per one transaction, should be less than dailyLimit, greater than minPerTx.
     * 0 value is also allowed, will stop the bridge operations in outgoing direction.
     */
    function setMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        tokensBridgeLimitsContract().setMaxPerTx(_token, _maxPerTx);
    }

    /**
     * @dev Updates minimum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _minPerTx minimum amount of tokens per one transaction, should be less than maxPerTx and dailyLimit.
     */
    function setMinPerTx(address _token, uint256 _minPerTx) external onlyOwner {
        tokensBridgeLimitsContract().setMinPerTx(_token, _minPerTx);
    }

    /**
     * @dev Retrieves maximum available bridge amount per one transaction taking into account maxPerTx() and dailyLimit() parameters.
     * @param _token address of the token contract, or address(0) for the default limit.
     * @return minimum of maxPerTx parameter and remaining daily quota.
     */
    function maxAvailablePerTx(address _token) public view returns (uint256) {
        return tokensBridgeLimitsContract().maxAvailablePerTx(_token);
    }

    /**
     * @dev Internal function for adding spent amount for some token.
     * @param _token address of the token contract.
     * @param _day day number, when tokens are processed.
     * @param _value amount of bridge tokens.
     */
    function addTotalSpentPerDay(
        address _token,
        uint256 _day,
        uint256 _value
    ) internal {
        // tokensBridgeLimitsContract().addTotalSpentPerDay(_token, _day, _value);
    }

    /**
     * @dev Internal function for adding executed amount for some token.
     * @param _token address of the token contract.
     * @param _day day number, when tokens are processed.
     * @param _value amount of bridge tokens.
     */
    function addTotalExecutedPerDay(
        address _token,
        uint256 _day,
        uint256 _value
    ) internal {
        // tokensBridgeLimitsContract().addTotalExecutedPerDay(_token, _day, _value);
    }

    /**
     * @dev Internal function for initializing limits for some token.
     * @param _token address of the token contract.
     * @param _limits [ 0 = dailyLimit, 1 = maxPerTx, 2 = minPerTx ].
     */
    function _setLimits(address _token, uint256[3] memory _limits) internal {
        // tokensBridgeLimitsContract()._setLimits(_token, _limits);
    }

    /**
     * @dev Internal function for initializing execution limits for some token.
     * @param _token address of the token contract.
     * @param _limits [ 0 = executionDailyLimit, 1 = executionMaxPerTx ].
     */
    function _setExecutionLimits(address _token, uint256[2] memory _limits) internal {
        // tokensBridgeLimitsContract()._setExecutionLimits(_token, _limits);
    }

    /**
     * @dev Internal function for initializing limits for some token relative to its decimals parameter.
     * @param _token address of the token contract.
     * @param _decimals token decimals parameter.
     */
    function _initializeTokenBridgeLimits(address _token, uint256 _decimals) internal {
        // tokensBridgeLimitsContract()._initializeTokenBridgeLimits(_token, _decimals);
    }
}
