pragma solidity 0.7.5;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../../../upgradeability/EternalStorage.sol";
import "../../Ownable.sol";

/**
 * @title TokensBridgeLimits
 * @dev Functionality for keeping track of bridging limits for multiple tokens.
 */
contract TokensBridgeLimits is Ownable {
    // token == 0x00..00 represents default limits (assuming decimals == 18) for all newly created tokens
    event DailyLimitChanged(address indexed token, uint256 newLimit);
    event ExecutionDailyLimitChanged(address indexed token, uint256 newLimit);

    /**
     * @dev Checks if specified token was already bridged at least once.
     * @param _token address of the token contract.
     * @return true, if token address is address(0) or token was already bridged.
     */
    function isTokenRegistered(address _token) public view returns (bool) {
        return false;
    }

    /**
     * @dev Retrieves the total spent amount for particular token during specific day.
     * @param _token address of the token contract.
     * @param _day day number for which spent amount if requested.
     * @return amount of tokens sent through the bridge to the other side.
     */
    function totalSpentPerDay(address _token, uint256 _day) public view returns (uint256) {
        return 0;
    }

    /**
     * @dev Retrieves the total executed amount for particular token during specific day.
     * @param _token address of the token contract.
     * @param _day day number for which spent amount if requested.
     * @return amount of tokens received from the bridge from the other side.
     */
    function totalExecutedPerDay(address _token, uint256 _day) public view returns (uint256) {
        return 0;
    }

    /**
     * @dev Retrieves current daily limit for a particular token contract.
     * @param _token address of the token contract.
     * @return daily limit on tokens that can be sent through the bridge per day.
     */
    function dailyLimit(address _token) public view returns (uint256) {
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    /**
     * @dev Retrieves current execution daily limit for a particular token contract.
     * @param _token address of the token contract.
     * @return daily limit on tokens that can be received from the bridge on the other side per day.
     */
    function executionDailyLimit(address _token) public view returns (uint256) {
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    /**
     * @dev Retrieves current maximum amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return maximum amount on tokens that can be sent through the bridge in one transfer.
     */
    function maxPerTx(address _token) public view returns (uint256) {
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    /**
     * @dev Retrieves current maximum execution amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return maximum amount on tokens that can received from the bridge on the other side in one transaction.
     */
    function executionMaxPerTx(address _token) public view returns (uint256) {
        return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    }

    /**
     * @dev Retrieves current minimum amount of tokens per one transfer for a particular token contract.
     * @param _token address of the token contract.
     * @return minimum amount on tokens that can be sent through the bridge in one transfer.
     */
    function minPerTx(address _token) public view returns (uint256) {
        return 0;
    }

    /**
     * @dev Checks that bridged amount of tokens conforms to the configured limits.
     * @param _token address of the token contract.
     * @param _amount amount of bridge tokens.
     * @return true, if specified amount can be bridged.
     */
    function withinLimit(address _token, uint256 _amount) public view returns (bool) {
        return true;
    }

    /**
     * @dev Checks that bridged amount of tokens conforms to the configured execution limits.
     * @param _token address of the token contract.
     * @param _amount amount of bridge tokens.
     * @return true, if specified amount can be processed and executed.
     */
    function withinExecutionLimit(address _token, uint256 _amount) public view returns (bool) {
        return true;
    }

    /**
     * @dev Returns current day number.
     * @return day number.
     */
    function getCurrentDay() public view returns (uint256) {
        // solhint-disable-next-line not-rely-on-time
        return block.timestamp / 1 days;
    }

    /**
     * @dev Updates daily limit for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the efault limit.
     * @param _dailyLimit daily allowed amount of bridged tokens, should be greater than maxPerTx.
     * 0 value is also allowed, will stop the bridge operations in outgoing direction.
     */
    function setDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        // revert();
    }

    /**
     * @dev Updates execution daily limit for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _dailyLimit daily allowed amount of executed tokens, should be greater than executionMaxPerTx.
     * 0 value is also allowed, will stop the bridge operations in incoming direction.
     */
    function setExecutionDailyLimit(address _token, uint256 _dailyLimit) external onlyOwner {
        // revert();
    }

    /**
     * @dev Updates execution maximum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _maxPerTx maximum amount of executed tokens per one transaction, should be less than executionDailyLimit.
     * 0 value is also allowed, will stop the bridge operations in incoming direction.
     */
    function setExecutionMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        // revert();
    }

    /**
     * @dev Updates maximum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _maxPerTx maximum amount of tokens per one transaction, should be less than dailyLimit, greater than minPerTx.
     * 0 value is also allowed, will stop the bridge operations in outgoing direction.
     */
    function setMaxPerTx(address _token, uint256 _maxPerTx) external onlyOwner {
        // revert();
    }

    /**
     * @dev Updates minimum per transaction for the particular token. Only owner can call this method.
     * @param _token address of the token contract, or address(0) for configuring the default limit.
     * @param _minPerTx minimum amount of tokens per one transaction, should be less than maxPerTx and dailyLimit.
     */
    function setMinPerTx(address _token, uint256 _minPerTx) external onlyOwner {
        // revert();
    }

    /**
     * @dev Retrieves maximum available bridge amount per one transaction taking into account maxPerTx() and dailyLimit() parameters.
     * @param _token address of the token contract, or address(0) for the default limit.
     * @return minimum of maxPerTx parameter and remaining daily quota.
     */
    function maxAvailablePerTx(address _token) public view returns (uint256) {
        // revert();
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
        // revert();
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
        // revert();
    }

    /**
     * @dev Internal function for initializing limits for some token.
     * @param _token address of the token contract.
     * @param _limits [ 0 = dailyLimit, 1 = maxPerTx, 2 = minPerTx ].
     */
    function _setLimits(address _token, uint256[3] memory _limits) internal {
        // revert();
    }

    /**
     * @dev Internal function for initializing execution limits for some token.
     * @param _token address of the token contract.
     * @param _limits [ 0 = executionDailyLimit, 1 = executionMaxPerTx ].
     */
    function _setExecutionLimits(address _token, uint256[2] memory _limits) internal {
        // revert();
    }

    /**
     * @dev Internal function for initializing limits for some token relative to its decimals parameter.
     * @param _token address of the token contract.
     * @param _decimals token decimals parameter.
     */
    function _initializeTokenBridgeLimits(address _token, uint256 _decimals) internal {
        // revert();
    }
}
