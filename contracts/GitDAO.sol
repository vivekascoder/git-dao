// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract GitDAO {
    mapping(string => address) public emailToAddress;

    constructor() {}

    function registerUser(string memory _email) external {
        require(emailToAddress[_email] == address(0), "USER_ALREADY_EXISTS");
        emailToAddress[_email] = msg.sender;
    }

    function changeAddress(string memory _oldEmail, address _address) external {
        require(
            emailToAddress[_oldEmail] != address(0),
            "USER_DOES_NOT_EXISTS"
        );
        emailToAddress[_oldEmail] = _address;
    }

    function rewardIndivisual(string memory _email, uint256 _tokenAmount)
        external
    {
        address userAddress = emailToAddress[_email];
        require(userAddress != address(0), "USER_DOES_NOT_EXISTS");

        // Send money from treasurey.
    }

    function buyTokens(
        address _to,
        uint256 _tokenAmount,
        uint256 _price
    ) external {}
}
