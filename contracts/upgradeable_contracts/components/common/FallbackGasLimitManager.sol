pragma solidity 0.7.5;

import "../../BasicAMBMediator.sol";
import "../../modules/gas_limit/SelectorTokenGasLimitConnector.sol";
import "../../modules/gas_limit/SelectorTokenGasLimitManager.sol";

/**
 * @title FallbackGasLimitManager
 * @dev Functionality for determining the request gas limit for AMB execution.
 */
abstract contract FallbackGasLimitManager is SelectorTokenGasLimitConnector {
    bytes32 internal constant REQUEST_GAS_LIMIT = 0x2dfd6c9f781bb6bbb5369c114e949b69ebb440ef3d4dd6b2836225eb1dc3a2be; // keccak256(abi.encodePacked("requestGasLimit"))

    /**
     * @dev Sets the default gas limit to be used in the message execution by the AMB bridge on the other network.
     * This value can't exceed the parameter maxGasPerTx defined on the AMB bridge.
     * Only the owner can call this method.
     * @param _gasLimit the gas limit for the message execution.
     */
    function setRequestGasLimit(uint256 _gasLimit) external onlyOwner {
        _setRequestGasLimit(_gasLimit);
    }

    /**
     * @dev Tells the default gas limit to be used in the message execution by the AMB bridge on the other network.
     * @return the gas limit for the message execution.
     */
    function requestGasLimit() public view returns (uint256) {
        SelectorTokenGasLimitManager manager = gasLimitManager();
        if (address(manager) == address(0)) {
            return uintStorage[REQUEST_GAS_LIMIT];
        } else {
            return manager.requestGasLimit();
        }
    }

    /**
     * @dev Stores the gas limit to be used in the message execution by the AMB bridge on the other network.
     * @param _gasLimit the gas limit for the message execution.
     */
    function _setRequestGasLimit(uint256 _gasLimit) internal {
        SelectorTokenGasLimitManager manager = gasLimitManager();
        if (address(manager) == address(0)) {
            require(_gasLimit <= maxGasPerTx());
            uintStorage[REQUEST_GAS_LIMIT] = _gasLimit;
        } else {
            return manager.setRequestGasLimit(_gasLimit);
        }
    }

    /**
     * @dev Tells the gas limit to use for the message execution by the AMB bridge on the other network.
     * @param _data calldata to be used on the other side of the bridge, when execution a message.
     * @return the gas limit for the message execution.
     */
    function _chooseRequestGasLimit(bytes memory _data) internal override view returns (uint256) {
        SelectorTokenGasLimitManager manager = gasLimitManager();
        if (address(manager) == address(0)) {
            return requestGasLimit();
        } else {
            return manager.requestGasLimit(_data);
        }
    }
}
