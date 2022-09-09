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
yarn run v1.22.19
$ /Users/vivekascoder/code/git_dao/node_modules/.bin/hardhat deploy --network polygonTestnet
Nothing to compile
No need to generate any newer typings.
----------------------------------------------------
Deploying the CreateDAOToken
deploying "CreateDAOToken" (tx: 0x9d4cbf8cd11d67d2a462e60924cdc6c2bca63212eb9acd1c8afc684d58b2327a)...: deployed at 0xC8cAE6f381d679a9A79E3ED4C64a6864f9a85541 with 5254516 gas
CreateDAOToken at 0xC8cAE6f381d679a9A79E3ED4C64a6864f9a85541
deploying "CreateGitDAO" (tx: 0x1621b70c885f1a55d983eb4203f4f7d32c3d83f05557c3fb34e2beb7b9aa407a)...: deployed at 0x0526818a27084d9d8B468d44D421FB309386872C with 1979183 gas
CreateDAOToken at 0x0526818a27084d9d8B468d44D421FB309386872C
reusing "CreateDAOTimelock" at 0xaFcbC84eE2F2543c88fdE38C9B0c28517dFe21fF
CreateDAOToken at 0xaFcbC84eE2F2543c88fdE38C9B0c28517dFe21fF
Deploying CreateDAO contract
deploying "CreateDAO" (tx: 0x26ed487c38e04fba0da6c470ee049d29531136107fc65a00395517a88155ff30)...: deployed at 0xd91E5C25bD1F9284194d47Cf1Df29F52464879E9 with 4718209 gas
CreateDAO at 0xd91E5C25bD1F9284194d47Cf1Df29F52464879E9
Deploying DAOFactory
DAOFactory at 0x33ddc9cD01Be9f68830da11D38E202eA0e1A467f
Verifying as well...
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/factories/CreateDAOToken.sol:CreateDAOToken at 0xC8cAE6f381d679a9A79E3ED4C64a6864f9a85541
for verification on the block explorer. Waiting for verification result...

Successfully verified contract CreateDAOToken on Etherscan.
https://mumbai.polygonscan.com/address/0xC8cAE6f381d679a9A79E3ED4C64a6864f9a85541#code
+ Verifying contract...
Generating typings for: 42 artifacts in dir: typechain-types for target: ethers-v5
Successfully generated 67 typings!
Compiled 40 Solidity files successfully
Successfully submitted source code for contract
contracts/factories/CreateDAO.sol:CreateDAO at 0xd91E5C25bD1F9284194d47Cf1Df29F52464879E9
for verification on the block explorer. Waiting for verification result...

Successfully verified contract CreateDAO on Etherscan.
https://mumbai.polygonscan.com/address/0xd91E5C25bD1F9284194d47Cf1Df29F52464879E9#code
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/DAOFactory.sol:DAOFactory at 0x33ddc9cD01Be9f68830da11D38E202eA0e1A467f
for verification on the block explorer. Waiting for verification result...

Successfully verified contract DAOFactory on Etherscan.
https://mumbai.polygonscan.com/address/0x33ddc9cD01Be9f68830da11D38E202eA0e1A467f#code
✨  Done in 165.25s.
```
