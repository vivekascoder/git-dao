// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DAOTimelock.sol";

contract CreateDAOTimelock {
    function createDAOTimelock(uint256 _minDelay) external returns (address) {
        DAOTimelock dtimelock = new DAOTimelock(
            _minDelay,
            new address[](0),
            new address[](0)
        );
        return address(dtimelock);
    }
}
