// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DAOToken.sol";

contract GitDAO is Ownable {
    // Events
    event UserRewarded(address user, uint256 amount);

    // Storage.
    struct DaoInfo {
        address dao;
        address daoTimelock;
        address daoToken;
    }
    DaoInfo dao;

    constructor(
        address _dao,
        address _daoTimelock,
        address _daoToken
    ) {
        dao.dao = _dao;
        dao.daoTimelock = _daoTimelock;
        dao.daoToken = _daoToken;
    }

    function getDaoInfo() public view returns (DaoInfo memory) {
        return dao;
    }

    function rewardIndivisual(address _userAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        require(_userAddress != address(0), "USER_DOES_NOT_EXISTS");

        // Send money from treasurey.
        DAOToken dt = DAOToken(dao.daoToken);
        dt.transfer(_userAddress, _tokenAmount);
        emit UserRewarded(_userAddress, _tokenAmount);
    }

    function buyTokens(
        address _to,
        uint256 _tokenAmount,
        uint256 _price
    ) external {}
}
