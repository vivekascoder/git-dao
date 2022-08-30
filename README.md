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
Generating typings for: 39 artifacts in dir: typechain-types for target: ethers-v5
Successfully generated 63 typings!
Compiled 35 Solidity files successfully
Successfully submitted source code for contract
contracts/DAOFactory.sol:CreateDAO at 0xe9b6357833C2cAd8b1FFe8FCbfEC6868f0693565
for verification on the block explorer. Waiting for verification result...

>> Successfully verified contract CreateDAO on Etherscan.
https://mumbai.polygonscan.com/address/0xe9b6357833C2cAd8b1FFe8FCbfEC6868f0693565#code
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/DAOFactory.sol:DAOFactory at 0xC8A7Ef44347f13683F624D1ef9736DE3e84D8e41
for verification on the block explorer. Waiting for verification result...

>> Successfully verified contract DAOFactory on Etherscan.
https://mumbai.polygonscan.com/address/0xC8A7Ef44347f13683F624D1ef9736DE3e84D8e41#code
✨  Done in 138.80s.
```
