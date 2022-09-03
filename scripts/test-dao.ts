import { ethers, network } from "hardhat";
import {
  developmentChains,
  VOTING_DELAY,
  VOTING_PERIOD,
  MIN_DELAY,
} from "../hardhat.config";
import { moveBlocks, moveTime } from "../utils";

const PROPOSAL_DESCRIPTION = "Just wanna vote";

const main = async () => {
  const [owner, bob] = await ethers.getSigners();
  const dao = await ethers.getContract("DAO");
  const gitDao = await ethers.getContract("GitDAO");
  const daoToken = await ethers.getContract("DAOToken");

  console.log(
    `> Token balance of bob before proposal: ${await daoToken.balanceOf(
      bob.address
    )}`
  );

  // # Testing the flow of DAO.

  // ## Propose

  // Reward `bob` with 10 tokens
  const encodedFunctionCall = gitDao.interface.encodeFunctionData(
    "rewardIndivisual",
    [bob.address, ethers.utils.parseEther("10")]
  );

  // Proposing the proposal
  const proposeTx = await dao.propose(
    [gitDao.address],
    [0],
    [encodedFunctionCall],
    PROPOSAL_DESCRIPTION
  );
  if (developmentChains.includes(network.name)) {
    await moveBlocks(VOTING_DELAY + 1);
  }

  const proposeReceipt = await proposeTx.wait(1);
  const proposalId = proposeReceipt.events[0].args.proposalId.toString();
  let proposalState = await dao.state(proposalId);
  const proposalSnapShot = await dao.proposalSnapshot(proposalId);
  const proposalDeadline = await dao.proposalDeadline(proposalId);

  console.log("Proposal Id: ", proposalId);
  // The state of the proposal. 1 is not passed. 0 is passed.
  console.log(`Current Proposal State: ${proposalState}`);
  // What block # the proposal was snapshot
  console.log(`Current Proposal Snapshot: ${proposalSnapShot}`);
  // The block number the proposal voting expires
  console.log(`Current Proposal Deadline: ${proposalDeadline}`);

  // ## Voting on the proposal.

  // voting by calling castVoteWithReason
  const voteTx = await dao.castVoteWithReason(
    proposalId,
    1,
    PROPOSAL_DESCRIPTION
  );
  const voteReceipt = await voteTx.wait(1);
  proposalState = await dao.state(proposalId);
  console.log(`> Current Proposal State: ${proposalState}`);
  console.log(`> Reason: ${voteReceipt.events[0].args.reason}`);

  // Skipping voting period.
  if (developmentChains.includes(network.name)) {
    await moveBlocks(VOTING_PERIOD + 1);
  }

  // ## Queue and Execute.

  const descriptionHash = ethers.utils.keccak256(
    ethers.utils.toUtf8Bytes(PROPOSAL_DESCRIPTION)
  );

  const hash = await dao.hashProposal(
    [gitDao.address],
    [0],
    [encodedFunctionCall],
    descriptionHash
  );
  console.log(`Calculated Hash: ${hash}`);

  // Queue transaciton.
  const queueTx = await dao.queue(
    [gitDao.address],
    [0],
    [encodedFunctionCall],
    descriptionHash
  );
  await queueTx.wait(1);

  // Skipvping min. time to vote.
  if (developmentChains.includes(network.name)) {
    await moveTime(MIN_DELAY + 1);
    await moveBlocks(1);
  }

  // Executing the proposal
  console.log(`> Starting the execution of proposal section`);
  const executeTx = await dao.execute(
    [gitDao.address],
    [0],
    [encodedFunctionCall],
    descriptionHash
  );
  await executeTx.wait(1);

  // Checking stuff after execution
  console.log(
    `> Token balance of bob after proposal: ${await daoToken.balanceOf(
      bob.address
    )}`
  );
};

main()
  .then((e) => process.exit(0))
  .catch((e) => console.error(e));
