// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DAOTimelock.sol";

contract CreateDAOTimelock {
    function createDAOTimelock(uint256 _minDelay, address _daoFactory)
        external
        returns (address)
    {
        DAOTimelock dtimelock = new DAOTimelock(
            _minDelay,
            new address[](0),
            new address[](0)
        );
        // Give dao contract admin rights.
        dtimelock.grantRole(dtimelock.TIMELOCK_ADMIN_ROLE(), _daoFactory);
        dtimelock.revokeRole(dtimelock.TIMELOCK_ADMIN_ROLE(), address(this));
        return address(dtimelock);
    }
}
