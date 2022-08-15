// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./DAO.sol";
import "./DAOToken.sol";
import "./DAOTimelock.sol";

/**
 * Factory that creates other DAO contracts.
 */
contract DAOFactory {
    address public admin;
    struct DAOInfo {
        address daoToken;
        address daoTimelock;
        address dao;
    }

    // UserAddress => [DAOInfo1, DAOInfo2, ...]
    mapping(address => DAOInfo[]) public userDaos;

    constructor(address _admin) {
        admin = _admin;
    }

    // Create DAOs
    function createDAO(
        string memory _daoTokenName,
        string memory _daoTokenSymbol,
        uint256 _daoTokenSupply,
        uint256 _minDelay,
        uint256 _quorumPercentage,
        uint256 _votingPeriod,
        uint256 _votingDelay
    ) external {
        // Create new token for DAO.
        DAOToken dtoken = new DAOToken(
            _daoTokenName,
            _daoTokenSymbol,
            _daoTokenSupply
        );

        // Create new timelock for DAO
        DAOTimelock dtimelock = new DAOTimelock(
            _minDelay,
            new address[](0),
            new address[](0)
        );

        // Create new Governance contract
        DAO dao = new DAO(
            dtoken,
            dtimelock,
            _quorumPercentage,
            _votingPeriod,
            _votingDelay
        );

        // Save the info
        DAOInfo[] storage dinfo = userDaos[msg.sender];
        dinfo.push(DAOInfo(address(dtoken), address(dtimelock), address(dao)));
    }
}
