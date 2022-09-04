# Git DAO

## Testing the DAO

```bash
yarn hardhat run ./scripts/test-dao.ts --network localhost
```

## Doc Stuff

### How queue works ?

```sol
/**
 * @dev Function to queue a proposal to the timelock.
 */
function queue(
  address[] memory targets,
  uint256[] memory values,
  bytes[] memory calldatas,
  bytes32 descriptionHash
) public virtual override returns (uint256) {
  uint256 proposalId = hashProposal(
    targets,
    values,
    calldatas,
    descriptionHash
  );

  require(
    state(proposalId) == ProposalState.Succeeded,
    "Governor: proposal not successful"
  );

  uint256 eta = block.timestamp + _timelock.delay();
  _proposalTimelocks[proposalId].timer.setDeadline(eta.toUint64());
  for (uint256 i = 0; i < targets.length; ++i) {
    require(
      !_timelock.queuedTransactions(
        keccak256(abi.encode(targets[i], values[i], "", calldatas[i], eta))
      ),
      "GovernorTimelockCompound: identical proposal action already queued"
    );
    _timelock.queueTransaction(targets[i], values[i], "", calldatas[i], eta);
  }

  emit ProposalQueued(proposalId, eta);

  return proposalId;
}

```

Iterate over and and the transactions to queue

```sol
for (uint256 i = 0; i < targets.length; ++i) {
    require(
        !_timelock.queuedTransactions(keccak256(abi.encode(targets[i], values[i], "", calldatas[i], eta))),
        "GovernorTimelockCompound: identical proposal action already queued"
    );
    _timelock.queueTransaction(targets[i], values[i], "", calldatas[i], eta);
}
```

## Executing the proposals

```sol
/**
 * @dev Overridden execute function that run the already queued proposal through the timelock.
 */
function _execute(
  uint256 proposalId,
  address[] memory targets,
  uint256[] memory values,
  bytes[] memory calldatas,
  bytes32 /*descriptionHash*/
) internal virtual override {
  uint256 eta = proposalEta(proposalId);
  require(eta > 0, "GovernorTimelockCompound: proposal not yet queued");
  Address.sendValue(payable(_timelock), msg.value);
  for (uint256 i = 0; i < targets.length; ++i) {
    _timelock.executeTransaction(targets[i], values[i], "", calldatas[i], eta);
  }
}

```

Iterate over the transactions and execute the proposal transactions

### Comments Standard

Netspec format: https://docs.soliditylang.org/en/v0.8.15/natspec-format.html

## TODO

- Maybe use EIP1167

- Governance treasury
  - https://forum.openzeppelin.com/t/how-to-add-funds-to-a-governor-treasury/22772
  - https://forum.openzeppelin.com/t/gnosis-safe-governor-timelock-as-treasury/17064

## Deployed contracts

```
----------------------------------------------------
Deploying the CreateDAOToken
deploying "CreateDAOToken" (tx: 0xbbbbe229f3340e30df5d2a4854a9cbbba955572962f80e8f86c203741b2de91e)...: deployed at 0x05bB07D3875AA5D05726B7993B846E2252aE6272 with 5234530 gas
CreateDAOToken at 0x05bB07D3875AA5D05726B7993B846E2252aE6272
deploying "CreateGitDAO" (tx: 0xbd7902a98ee277aad4f2a357160eaf23dcfca0a44c7ee8b910d68125a632f20a)...: deployed at 0x1465D39dFBC06B91C9Fe42fC6Cc642f62Be6916F with 1979183 gas
CreateDAOToken at 0x1465D39dFBC06B91C9Fe42fC6Cc642f62Be6916F
deploying "CreateDAOTimelock" (tx: 0x95702f50a147c47cfc259c4816264f39bb7612c46029d19afd60a6c4750f3a3a)...: deployed at 0xaFcbC84eE2F2543c88fdE38C9B0c28517dFe21fF with 3485667 gas
CreateDAOToken at 0xaFcbC84eE2F2543c88fdE38C9B0c28517dFe21fF
Deploying CreateDAO contract
deploying "CreateDAO" (tx: 0xde9b20bf01e3256f24dd11e4cfc0fff6db40424a5c7463ccaeb15baf75fec224)...: deployed at 0x8843dE736048681115b6aF95F71674A263432C2E with 4718209 gas
CreateDAO at 0x8843dE736048681115b6aF95F71674A263432C2E
Deploying DAOFactory
DAOFactory at 0xBCD2F6aC5c04B6b8C1D3700B8Ae98609FB578830
Verifying as well...
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/factories/CreateDAOToken.sol:CreateDAOToken at 0x05bB07D3875AA5D05726B7993B846E2252aE6272
for verification on the block explorer. Waiting for verification result...

Successfully verified contract CreateDAOToken on Etherscan.
https://mumbai.polygonscan.com/address/0x05bB07D3875AA5D05726B7993B846E2252aE6272#code
+ Verifying contract...
Generating typings for: 42 artifacts in dir: typechain-types for target: ethers-v5
Successfully generated 67 typings!
Compiled 40 Solidity files successfully
Successfully submitted source code for contract
contracts/factories/CreateDAO.sol:CreateDAO at 0x8843dE736048681115b6aF95F71674A263432C2E
for verification on the block explorer. Waiting for verification result...

Successfully verified contract CreateDAO on Etherscan.
https://mumbai.polygonscan.com/address/0x8843dE736048681115b6aF95F71674A263432C2E#code
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/DAOFactory.sol:DAOFactory at 0xBCD2F6aC5c04B6b8C1D3700B8Ae98609FB578830
for verification on the block explorer. Waiting for verification result...

Successfully verified contract DAOFactory on Etherscan.
https://mumbai.polygonscan.com/address/0xBCD2F6aC5c04B6b8C1D3700B8Ae98609FB578830#code
✨  Done in 177.67s.
```
