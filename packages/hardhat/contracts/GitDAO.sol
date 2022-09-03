// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DAOToken.sol";

/**
 * ## Currently you have two features.
 * + Reward a user.
 * + Token sale.
 */
contract GitDAO is Ownable {
    // Events
    event UserRewarded(address user, uint256 amount);
    event TokenSale(
        address to,
        uint256 tokenAmount,
        uint256 price,
        address erc20
    );

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

    /// @dev Hey, this is dev doc.
    function rewardIndivisual(address _userAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        // msg.sender is dao contract.
        require(_userAddress != address(0), "USER_DOES_NOT_EXISTS");

        // Send money from treasurey.
        DAOToken dt = DAOToken(dao.daoToken);
        dt.transfer(_userAddress, _tokenAmount);
        emit UserRewarded(_userAddress, _tokenAmount);
    }

    /**
     * @param _to User who wants to but tokens.
     * @param _tokenAmount Amount of token that user wants to buy.
     * @param _price The price of one dao token at which user's buying out dao tokens.
     * @param _erc20 The token which we'll get in return.
     */
    function buyTokensWithERC20(
        address _to,
        uint256 _tokenAmount,
        uint256 _price,
        address _erc20
    ) external onlyOwner {
        require(_to != address(0), "USER_DOES_NOT_EXISTS");

        // Transfer the value to the DAO treasury.
        IERC20 erc20 = IERC20(_erc20);
        erc20.transferFrom(_to, dao.dao, _price * _tokenAmount); // from, to, price.

        // Sell the tokens.
        DAOToken dt = DAOToken(dao.daoToken);
        dt.transferFrom(_to, dao.dao, _tokenAmount);

        emit TokenSale(_to, _tokenAmount, _price, _erc20);
    }
}
