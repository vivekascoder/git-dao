// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DAOToken.sol";

// Interfaces.
import {ISuperTokenFactory} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperTokenFactory.sol";
import {ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperToken.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

/// @dev Superfluid token addresses on polygon mumbai testnet.
library SuperfluidContracts {
    address constant SuperTokenFactory = 0x200657E2f123761662567A1744f9ACAe50dF47E6;
}

/// @dev Main contract for DAO.
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
    DaoInfo public dao;
    string public githubUrl;
    string public githubId;

    // Superfluid factory contract.
    address superTokenFactory = SuperfluidContracts.SuperTokenFactory;
    address wrapToken;

    modifier superTokenExists {
        require(wrapToken != address(0), "super token does not exists.");
        _;
    }


    constructor(
        address _dao,
        address _daoTimelock,
        address _daoToken,
        string memory _githubUrl,
        string memory _githubId
    ) {
        dao.dao = _dao;
        dao.daoTimelock = _daoTimelock;
        dao.daoToken = _daoToken;

        // Github metadata.
        githubId = _githubId;
        githubUrl = _githubUrl;
    }

    function getDaoInfo() public view returns (DaoInfo memory) {
        return dao;
    }

    /// @dev Hey, this is dev doc.
    function rewardIndivisual(address _userAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        console.log("Origin: %s", tx.origin);
        console.log("Sender: %s", msg.sender);
        console.log("Owner: %s", owner());
        // msg.sender is dao contract.
        require(_userAddress != address(0), "USER_DOES_NOT_EXISTS");

        // Send money from treasurey.
        IERC20 dt = IERC20(dao.daoToken);
        console.log("Balance Of this %s", dt.balanceOf(address(this)));
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
        require(_price > 0, "Price > 0");
        require(_tokenAmount > 0, "TokenAmount > 0");

        // Transfer the value to the DAO treasury.
        IERC20 erc20 = IERC20(_erc20);
        // FIXME: dao.dao -> address(this)
        console.log("WAiting 1");
        erc20.transferFrom(_to, address(this), _price * _tokenAmount); // from, to, price.
        console.log("Transfered 1");

        // Sell the tokens.
        DAOToken dt = DAOToken(dao.daoToken);
        dt.transfer(_to, _tokenAmount);

        emit TokenSale(_to, _tokenAmount, _price, _erc20);
    }

    // function createWrapToken() external onlyOwner {
    //     // Check if wrapToken doesn't exists.
    //     require(wrapToken == address(0), "wrap token already exists.");

    //     // Dao Token object.
    //     IERC20Metadata erc20 = IERC20Metadata(dao.daoToken);

    //     // Create wrap token contract.
    //     ISuperTokenFactory factory = ISuperTokenFactory(superTokenFactory);
    //     ISuperToken wrappedToken = factory.createERC20Wrapper(
    //         dao.daoToken,
    //         erc20.decimals(),
    //         2,
    //         erc20.name(),
    //         erc20.symbol()
    //     );
        

    //     // Save the created token contract address.
    //     wrapToken = address(wrappedToken);
    // }

    // function rewardIndivisualStream(address _user, uint _amount) external superTokenExists{
    //     IERC20Metadata erc20 = IERC20Metadata(dao.daoToken);
    //     ISuperToken superToken = ISuperToken(wrapToken); 

    //     // Wrap _amount tokens.
    //     superToken.upgrade(_amount);

    //     // Stream _amount tokens to _user.
    //     superToken.a 
    // }
}
