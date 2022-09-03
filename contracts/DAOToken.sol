// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract DAOToken is ERC20Votes {
    // uint256 public s_maxSupply = 1000000000000000000000000;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _adminPercent,
        address _daoContract
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        // Mint adminPercent% of tokens for admin.
        _mint(msg.sender, (_adminPercent * _maxSupply) / 100);
        // Mint the rest in the treasurey i.e DAO contract.
        _mint(_daoContract, (_maxSupply * (100 - _adminPercent)) / 100);
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
