// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../GitDAO.sol";

contract CreateGitDAO {
    function createGitDAO(
        // address _dao,
        // address _daoTimelock,
        // address _daoToken,
        address[3] memory daoAddresses,
        string memory _gitUrl,
        string memory _gitId
    ) external returns (GitDAO) {
        // Deploy a GitDAO Instance
        GitDAO gd = new GitDAO(
            daoAddresses[0],
            daoAddresses[1],
            daoAddresses[2],
            _gitUrl,
            _gitId
        );
        return gd;
    }
}
