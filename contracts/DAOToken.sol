// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DAOToken is ERC20Votes, Ownable {
    uint256 public amoutToMintForTreasury;
    address public daoContract;
    bool public isMinted = false;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _adminPercent
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        // Mint adminPercent% of tokens for admin.
        _mint(tx.origin, (_adminPercent * _maxSupply) / 100);
        amoutToMintForTreasury =
            _maxSupply -
            (_adminPercent * _maxSupply) /
            100;
        // Admin should be tx.origin as this represents the address of the user.
        // console.log("Transaction Origin: %s", tx.origin);
        console.log("Origin's balance: %s", super.balanceOf(tx.origin));
        // _transferOwnership(tx.origin);
    }

    function setDaoContract(address _dao) external onlyOwner {
        daoContract = _dao;
    }

    function sendToDAO() external onlyOwner {
        require(daoContract != address(0), "Address is 0 address.");
        require(isMinted == false, "Already minted.");
        // Mint the rest in the treasurey i.e DAO contract.
        _mint(daoContract, amoutToMintForTreasury);
        isMinted = true;
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount);
    }
}
