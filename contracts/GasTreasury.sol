// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title GasTreasury
 * @dev Holds AKB transfer fees and ETH for protocol operations.
 */
contract GasTreasury is Ownable {
    event TokensWithdrawn(address indexed token, uint256 amount);
    event EthWithdrawn(uint256 amount);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
        emit TokensWithdrawn(token, amount);
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
        emit EthWithdrawn(amount);
    }

    receive() external payable {}
}