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
reusing "CreateDAOToken" at 0xFE2f58bA328729bB3353910B9Fd255f35cbdaEC4
CreateDAOToken at 0xFE2f58bA328729bB3353910B9Fd255f35cbdaEC4
reusing "CreateGitDAO" at 0x3f60A535BcaF9b522eCB06c3453B9C375929bA28
CreateDAOToken at 0x3f60A535BcaF9b522eCB06c3453B9C375929bA28
reusing "CreateDAOTimelock" at 0x3107b7B3e57C31788003799C238E9171FEBE57fe
CreateDAOToken at 0x3107b7B3e57C31788003799C238E9171FEBE57fe
Deploying CreateDAO contract
reusing "CreateDAO" at 0xA850a4FdDcE766230DA2AaC917fa59eC0F8F873B
CreateDAO at 0xA850a4FdDcE766230DA2AaC917fa59eC0F8F873B
Deploying DAOFactory
DAOFactory at 0x1b626A54106113691F7858ea4B5406834506D866
Verifying as well...
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Already verified!
+ Verifying contract...
Generating typings for: 42 artifacts in dir: typechain-types for target: ethers-v5
Successfully generated 67 typings!
Compiled 40 Solidity files successfully
Already verified!
+ Verifying contract...
Nothing to compile
No need to generate any newer typings.
Successfully submitted source code for contract
contracts/DAOFactory.sol:DAOFactory at 0x1b626A54106113691F7858ea4B5406834506D866
for verification on the block explorer. Waiting for verification result...

Successfully verified contract DAOFactory on Etherscan.
https://mumbai.polygonscan.com/address/0x1b626A54106113691F7858ea4B5406834506D866#code
✨  Done in 86.59s.
```
