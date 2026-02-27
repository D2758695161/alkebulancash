// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title AlkebulanCash (AKB)
 * @dev ERC20 token with fixed supply, transfer fee, whitelist, and pause.
 * Upgradeable via OpenZeppelin Initializable pattern.
 */
contract AlkebulanCash is
    Initializable,
    ERC20Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    /// @notice Admin role for protocol management
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Fixed maximum supply: 25,000,000 AKB
    uint256 public constant MAX_SUPPLY = 25_000_000 * 10 ** 18;

    /// @notice Transfer fee: 0.1% (10 basis points)
    uint256 public constant FEE_BASIS_POINTS = 10;

    /// @notice Treasury that receives transfer fees
    address public gasTreasury;

    /// @notice Addresses exempt from fees
    mapping(address => bool) public isWhitelisted;

    /// @notice Emitted when treasury address changes
    event TreasuryUpdated(address indexed newTreasury);

    /// @notice Emitted when whitelist status changes
    event WhitelistUpdated(address indexed account, bool status);

    /**
     * @notice Initializer (replaces constructor for upgradeable contracts)
     * @param _gasTreasury Address that will receive transfer fees
     */
    function initialize(address _gasTreasury) public initializer {
        require(_gasTreasury != address(0), "Invalid treasury");

        __ERC20_init("AlkebulanCash", "AKB");
        __AccessControl_init();
        __Pausable_init();

        // Assign roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);

        // Set treasury
        gasTreasury = _gasTreasury;

        // Mint fixed supply ONCE
        _mint(msg.sender, MAX_SUPPLY);

        // Fee exemptions
        isWhitelisted[msg.sender] = true;
        isWhitelisted[_gasTreasury] = true;
    }

    /**
     * @notice Update whitelist status for an address
     */
    function setWhitelist(address account, bool status)
        external
        onlyRole(ADMIN_ROLE)
    {
        isWhitelisted[account] = status;
        emit WhitelistUpdated(account, status);
    }

    /**
     * @notice Pause all token transfers
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause token transfers
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Internal transfer hook with fee logic
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        // No fees on mint, burn, or whitelisted addresses
        if (
            from == address(0) ||
            to == address(0) ||
            isWhitelisted[from] ||
            isWhitelisted[to]
        ) {
            super._update(from, to, amount);
            return;
        }

        uint256 fee = (amount * FEE_BASIS_POINTS) / 10_000;
        uint256 remainder = amount - fee;

        super._update(from, gasTreasury, fee);
        super._update(from, to, remainder);
    }
}