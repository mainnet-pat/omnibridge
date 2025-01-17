pragma solidity 0.7.5;

import "./Ownable.sol";
import "../interfaces/IAMB.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title BasicAMBMediator
 * @dev Basic storage and methods needed by mediators to interact with AMB bridge.
 */
abstract contract BasicAMBMediator is Ownable {
    bytes32 internal constant BRIDGE_CONTRACT = 0x811bbb11e8899da471f0e69a3ed55090fc90215227fc5fb1cb0d6e962ea7b74f; // keccak256(abi.encodePacked("bridgeContract"))
    bytes32 internal constant MEDIATOR_CONTRACT = 0x98aa806e31e94a687a31c65769cb99670064dd7f5a87526da075c5fb4eab9880; // keccak256(abi.encodePacked("mediatorContract"))

    // flat fee for passing a message to the bridge, charged in native chain currency
    bytes32 internal constant PASS_MESSAGE_FLAT_FEE = 0xe713e8a2958f781fac655015fde105575255d35cded381d57262a1013c6d1350; // keccak256(abi.encodePacked("passMessageFlatFee"));

    // amount of gas to be gifted to the destination account if its balance is 0
    // gas will be paid from mediator's balance
    bytes32 internal constant FREE_GAS_AMOUNT = 0x5f55ef54c9680958008e33d29974c1a05ba5e813f6318d80f38e41e29633e490; // keccak256(abi.encodePacked("freeGasAmount"));

    /**
     * @dev Throws if caller on the other side is not an associated mediator.
     */
    modifier onlyMediator {
        _onlyMediator();
        _;
    }

    /**
     * @dev Internal function for reducing onlyMediator modifier bytecode overhead.
     */
    function _onlyMediator() internal view {
        IAMB bridge = bridgeContract();
        require(msg.sender == address(bridge));
        require(bridge.messageSender() == mediatorContractOnOtherSide());
    }

    /**
     * @dev Sets the AMB bridge contract address. Only the owner can call this method.
     * @param _bridgeContract the address of the bridge contract.
     */
    function setBridgeContract(address _bridgeContract) external onlyOwner {
        _setBridgeContract(_bridgeContract);
    }

    /**
     * @dev Sets the mediator contract address from the other network. Only the owner can call this method.
     * @param _mediatorContract the address of the mediator contract.
     */
    function setMediatorContractOnOtherSide(address _mediatorContract) external onlyOwner {
        _setMediatorContractOnOtherSide(_mediatorContract);
    }

    /**
     * @dev Get the AMB interface for the bridge contract address
     * @return AMB interface for the bridge contract address
     */
    function bridgeContract() public view returns (IAMB) {
        return IAMB(addressStorage[BRIDGE_CONTRACT]);
    }

    /**
     * @dev Tells the mediator contract address from the other network.
     * @return the address of the mediator contract.
     */
    function mediatorContractOnOtherSide() public view virtual returns (address) {
        return addressStorage[MEDIATOR_CONTRACT];
    }

    /**
     * @dev Stores a valid AMB bridge contract address.
     * @param _bridgeContract the address of the bridge contract.
     */
    function _setBridgeContract(address _bridgeContract) internal {
        require(Address.isContract(_bridgeContract));
        addressStorage[BRIDGE_CONTRACT] = _bridgeContract;
    }

    /**
     * @dev Stores the mediator contract address from the other network.
     * @param _mediatorContract the address of the mediator contract.
     */
    function _setMediatorContractOnOtherSide(address _mediatorContract) internal {
        addressStorage[MEDIATOR_CONTRACT] = _mediatorContract;
    }

    /**
     * @dev Tells the id of the message originated on the other network.
     * @return the id of the message originated on the other network.
     */
    function messageId() internal view returns (bytes32) {
        return bridgeContract().messageId();
    }

    /**
     * @dev Tells the maximum gas limit that a message can use on its execution by the AMB bridge on the other network.
     * @return the maximum gas limit value.
     */
    function maxGasPerTx() internal view returns (uint256) {
        return bridgeContract().maxGasPerTx();
    }

    function _passMessage(bytes memory _data, bool _useOracleLane) internal virtual returns (bytes32);

    /**
     * @dev Sets the flat fee in chain's native coin to be paid for message relay. Only the owner can call this method.
     * @param _fee fee value.
     */
    function setPassMessageFlatFee(uint256 _fee) external onlyOwner {
        uintStorage[PASS_MESSAGE_FLAT_FEE] = _fee;
    }

    /**
     * @dev Gets the flat fee in chain's native coin to be paid for message relay.
     * @return fee value.
     */
    function passMessageFlatFee() public view virtual returns (uint256) {
        return uintStorage[PASS_MESSAGE_FLAT_FEE];
    }

    /**
     * @dev Sets amount of gas to be gifted to the destination account if its balance is 0. Only the owner can call this method.
     * @param _gas free gas amount.
     */
    function setFreeGasAmount(uint256 _gas) external onlyOwner {
        uintStorage[FREE_GAS_AMOUNT] = _gas;
    }

    /**
     * @dev Gets amount of gas to be gifted to the destination account if its balance is 0.
     * @return _gas value.
     */
    function freeGasAmount() public view virtual returns (uint256) {
        return uintStorage[FREE_GAS_AMOUNT];
    }

    receive() external payable {}
}
