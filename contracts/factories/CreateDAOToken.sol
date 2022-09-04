// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DAOToken.sol";

/**
 * Factory for DAO token contract.
 */
contract CreateDAOToken {
    function createDAOToken(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _adminPercent,
        address _daoFactory
    ) external returns (address) {
        DAOToken dt = new DAOToken(_name, _symbol, _maxSupply, _adminPercent);
        dt.transferOwnership(_daoFactory);
        return address(dt);
    }
}
