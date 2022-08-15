// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * Factory that creates other DAO contracts.
 */
contract DAOFactory {
    address public admin;

    constructor(address _admin) {
        admin = _admin;
    }

    // Create DAOs
    function createDAO() external {
        // Do something
    }
}
