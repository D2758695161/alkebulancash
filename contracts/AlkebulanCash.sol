// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @title AlkebulanCash (AKBC)
 * @dev ERC20 token with fixed supply, transfer fee, whitelist, pause,
 *      and on-chain governance support (ERC20Votes).
 *      OPTIMIZED: ReentrancyGuard on _update, redundant checks removed.
 */
contract AlkebulanCash is
    Initializable,
    ERC20Upgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    /// @notice Admin role for protocol management
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Fixed maximum supply: 25,000,000 AKBC
    uint256 public constant MAX_SUPPLY = 25_000_000 * 10 ** 18;

    /// @notice Transfer fee: 0.1% (10 basis points)
    uint256 public constant FEE_BASIS_POINTS = 10;

    /// @notice Treasury that receives transfer fees
    address public gasTreasury;

    /// @notice Addresses exempt from fees
    mapping(address => bool) public isWhitelisted;

    /// @notice Emitted when whitelist status changes
    event WhitelistUpdated(address indexed account, bool status);

    /// @notice Emitted when treasury address changes
    event TreasuryUpdated(address indexed newTreasury);

    /**
     * @notice Initializer (replaces constructor for upgradeable contracts)
     * @param _gasTreasury Address that will receive transfer fees
     */
    function initialize(address _gasTreasury) public initializer {
        require(_gasTreasury != address(0), "Invalid treasury");

        __ERC20_init("AlkebulanCash", "AKBC");
        __ERC20Votes_init();
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

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
     * @notice Update whitelist status
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
     * @dev Internal transfer hook with fee + governance safety + reentrancy protection.
     *      OPTIMIZATIONS:
     *      1. nonReentrant guard — _update makes 2 consecutive external calls (fee + remainder).
     *         Without this, a malicious contract could re-enter via receive()/fallback() between
     *         the two super._update() calls, potentially draining fees or manipulating state.
     *      2. Removed redundant checks: from==to (amount unchanged, fee 0, effect is no-op)
     *         and msg.sender==address(this) (this contract never initiates transfers).
     */
    function _update(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
        whenNotPaused
        nonReentrant
    {
        // Skip fee for: minting, burning, zero amount, or whitelisted addresses
        if (
            from == address(0) ||
            to == address(0) ||
            amount == 0 ||
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

    /**
     * @dev Required override for AccessControl + ERC165
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
