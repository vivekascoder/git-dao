// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./DAO.sol";
import "./DAOToken.sol";
import "./DAOTimelock.sol";
import "./GitDAO.sol";

// Import all the factories.
import "./factories/CreateDAO.sol";
import "./factories/CreateDAOTimelock.sol";
import "./factories/CreateDAOToken.sol";
import "./factories/CreateGitDAO.sol";

/**
 * Factory that creates other DAO contracts.
 */
contract DAOFactory {
    // Events
    event DAOCreated(
        DAOInfo dinfo,
        address[2] gitDaoCreator,
        string gitUrl,
        string gitId
    );
    // address gitDao,
    //     address creator,
    // string githubName

    address public admin;

    struct Factories {
        address daoTokenFactory;
        address createDAOContract;
        address createDAOTimelock;
        address createGitDAO;
    }
    Factories public factories;

    struct DAOInfo {
        address daoToken;
        address daoTimelock;
        address dao;
        bool exists;
    }
    uint256 maxPercentForAdmin;

    // UserAddress => [DAOInfo1, DAOInfo2, ...]
    mapping(string => DAOInfo) public GithubRepoNameToDAOInfo;

    mapping(address => mapping(string => DAOInfo)) public userDaos;

    constructor(
        address _admin,
        address _daoTokenFactory,
        address _createDAOContract,
        address _createDAOTimelock,
        address _createGitDAO,
        uint256 _maxPercentForAdmin
    ) {
        admin = _admin;
        factories.daoTokenFactory = _daoTokenFactory;
        factories.createDAOContract = _createDAOContract;
        maxPercentForAdmin = _maxPercentForAdmin;
        factories.createDAOTimelock = _createDAOTimelock;
        factories.createGitDAO = _createGitDAO;
    }

    // TODO: Some helper functions
    // function getDaoInfo

    // Create DAOs
    function createDAO(
        string memory _daoTokenName,
        string memory _daoTokenSymbol,
        uint256 _daoTokenSupply,
        uint256 _percentForAdmin,
        uint256 _minDelay,
        uint256 _quorumPercentage,
        uint256 _votingPeriod,
        uint256 _votingDelay,
        string memory _githubUrl, // vivek/git-dao
        string memory _githubId // Some unique identifier from github
    ) external {
        // TODO: Check if the user has already created repo for this url.
        DAOInfo storage dinfo = userDaos[msg.sender][_githubUrl];
        if (dinfo.exists) {
            revert("Looks like the dao already exists for this repo.");
        }
        if (_percentForAdmin > maxPercentForAdmin) {
            revert("You can't reserve that much for yourself.");
        }
        // NOTE: This is v. alpha in future this process will be done my a signer to make it more decentralized.
        // Create new token for DAO.
        CreateDAOToken dtf = CreateDAOToken(factories.daoTokenFactory);
        address dtoken = dtf.createDAOToken(
            _daoTokenName,
            _daoTokenSymbol,
            _daoTokenSupply,
            _percentForAdmin
        );

        // Create new timelock for DAO
        CreateDAOTimelock cdt = CreateDAOTimelock(factories.createDAOTimelock);
        address dtimelock = cdt.createDAOTimelock(_minDelay);

        // Create new Governance contract
        CreateDAO cd = CreateDAO(factories.createDAOContract);
        address dao = cd.createDAO(
            dtoken,
            dtimelock,
            _quorumPercentage,
            _votingPeriod,
            _votingDelay
        );

        // Save the info
        dinfo.daoToken = dtoken;
        dinfo.daoTimelock = dtimelock;
        dinfo.dao = dao;
        dinfo.exists = true;

        // Post deployment step.
        DAOTimelock dtimelockObject = DAOTimelock(payable(dtimelock));
        dtimelockObject.grantRole(dtimelockObject.PROPOSER_ROLE(), dao); // DAO can propose.
        dtimelockObject.grantRole(dtimelockObject.EXECUTOR_ROLE(), address(0));
        dtimelockObject.revokeRole(
            dtimelockObject.TIMELOCK_ADMIN_ROLE(),
            msg.sender
        ); // Admin's power gone.

        CreateGitDAO cgd = CreateGitDAO(factories.createGitDAO);
        GitDAO gd = cgd.createGitDAO(
            [dao, dtimelock, dtoken],
            _githubUrl,
            _githubId
        );

        // Mint to treasury.
        DAOToken dto = DAOToken(dtoken);
        dto.setDaoContract(address(gd));
        dto.sendToDAO();

        emit DAOCreated(
            dinfo,
            [address(gd), msg.sender],
            _githubUrl,
            _githubId
        );
    }
}
