// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./DAO.sol";
import "./DAOToken.sol";
import "./DAOTimelock.sol";

/**
 * Factory for DAO token contract.
 */
contract CreateDAOToken {
    function createDAOToken(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) external returns (address) {
        DAOToken dt = new DAOToken(_name, _symbol, _maxSupply);
        return address(dt);
    }
}

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

/**
 * Factory that creates other DAO contracts.
 */
contract DAOFactory {
    // Events
    event DAOCreated(
        address daoToken,
        address daoTimelock,
        address dao,
        address creator,
        string githubName,
        string githubId
    );

    address public admin;
    address public daoTokenFactory;
    address public createDAOContract;
    struct DAOInfo {
        address daoToken;
        address daoTimelock;
        address dao;
    }

    // UserAddress => [DAOInfo1, DAOInfo2, ...]
    mapping(address => DAOInfo[]) public userDaos;

    constructor(
        address _admin,
        address _daoTokenFactory,
        address _createDAOContract
    ) {
        admin = _admin;
        daoTokenFactory = _daoTokenFactory;
        createDAOContract = _createDAOContract;
    }

    // TODO: Some helper functions

    // Create DAOs
    function createDAO(
        string memory _daoTokenName,
        string memory _daoTokenSymbol,
        uint256 _daoTokenSupply,
        uint256 _minDelay,
        uint256 _quorumPercentage,
        uint256 _votingPeriod,
        uint256 _votingDelay,
        string memory _githubUrl, // vivek/git-dao
        string memory _githubId // Some unique identifier from github
    ) external {
        // Create new token for DAO.
        CreateDAOToken dtf = CreateDAOToken(daoTokenFactory);
        address dtoken = dtf.createDAOToken(
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
        CreateDAO cd = CreateDAO(createDAOContract);
        address dao = cd.createDAO(
            dtoken,
            address(dtimelock),
            _quorumPercentage,
            _votingPeriod,
            _votingDelay
        );

        // Save the info
        DAOInfo[] storage dinfo = userDaos[msg.sender];
        dinfo.push(DAOInfo(address(dtoken), address(dtimelock), address(dao)));
        emit DAOCreated(
            dtoken,
            address(dtimelock),
            dao,
            msg.sender,
            _githubUrl,
            _githubId
        );
    }
}
