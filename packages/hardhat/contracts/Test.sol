// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AFactory {
    address _proxy;
    address _newA;

    constructor(address _p) {
        _proxy = _p;
    }

    function createA(uint256 _initial) external returns (address) {
        CreateAContract cac = CreateAContract(_proxy);
        address newa = cac.create(_initial);
        _newA = newa;
        return newa;
    }

    function getA() public view returns (address) {
        return _newA;
    }
}

contract CreateAContract {
    function create(uint256 _initial) external returns (address) {
        A a = new A(_initial);
        return address(a);
    }
}

contract A {
    uint256 public value;

    constructor(uint256 _initial) {
        value = _initial;
    }
}
