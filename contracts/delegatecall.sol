// SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.9;

contract TestDelegateCall {
  uint public num;
  address public sender;
  uint public value;

  function setVars(uint _num) external payable {
    num = _num;
    sender = msg.sender;
    value = msg.value;
  }
}


// Executes setVars in TestDelegateCall with the storage of DelegateCall.
contract DelegateCall {
  uint public num;
  address public sender;
  uint public value;


  function setVars(address _test, uint _num) external payable {
    // (bool success, bytes memory data) = _test.delegatecall(
    //   abi.encodeWithSignature(
    //     abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num)
    //   )
    // );
    // require(success, "delegate call failed.");
  }
}
