// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DAO.sol";
import "../DAOTimelock.sol";
import "../DAOToken.sol";

/**
 * Factory for DAO / Governance Contract
 */
contract CreateDAO {
    function createDAO(
        address _daoToken,
        address _daoTimelock,
        uint256 _quorumPercentage,
        uint256 _votingPeriod,
        uint256 _votingDelay
    ) external returns (address) {
        DAO d = new DAO(
            DAOToken(_daoToken),
            DAOTimelock(payable(_daoTimelock)),
            _quorumPercentage,
            _votingPeriod,
            _votingDelay
        );
        return address(d);
    }
}
