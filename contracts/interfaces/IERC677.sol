pragma solidity 0.7.5;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC677 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}
