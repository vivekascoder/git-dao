import { BigNumber } from "ethers";
import { ethers, network } from "hardhat";
import {
  developmentChains,
  VOTING_DELAY,
  VOTING_PERIOD,
  MIN_DELAY,
} from "../hardhat.config";
import { moveBlocks, moveTime } from "../utils";

const PROPOSAL_DESCRIPTION = "Just wanna vote";
const DAO_TOTAL_SUPPLY = BigNumber.from("1000000000000000000000000");
const QUORUM_TOTAL = BigNumber.from(
  DAO_TOTAL_SUPPLY.mul(BigNumber.from(4)).div(BigNumber.from(100))
  // .sub(BigNumber.from(1))
);

const main = async () => {
  const [owner, bob, alice, ram] = await ethers.getSigners();
  const dao = await ethers.getContract("DAO");
  const gitDao = await ethers.getContract("GitDAO");
  const daoToken = await ethers.getContract("DAOToken");
  const Token = await ethers.getContractFactory("DAOToken");
  const token = await Token.deploy(
    "Super Token",
    "SDT",
    ethers.utils.parseEther("1000000"),
    20
  );

  console.log(
    "Admin balance of new token: ",
    (await token.balanceOf(owner.address)).toString()
  );

  console.log(
    "GitDAO balance of dao token: ",
    (await daoToken.balanceOf(gitDao.address)).toString()
  );

  await (
    await token.transfer(ram.address, ethers.utils.parseEther("1000"))
  ).wait(1);

  console.log(
    `> Ram owns ${(await token.balanceOf(ram.address)).toString()} new token.`
  );
  console.log(
    `> Ram owns ${(
      await daoToken.balanceOf(ram.address)
    ).toString()} dao token.`
  );

  console.log(
    "> Token balance of admin:",
    (await daoToken.balanceOf(alice.address)).toString()
  );
  const transferTx = await daoToken.transfer(alice.address, QUORUM_TOTAL);
  await transferTx.wait(1);
  // Delegate to alice from alice.
  await (await daoToken.connect(alice).delegate(alice.address)).wait(1);
  console.log(
    "> Token balance of admin after transfer:",
    (await daoToken.balanceOf(owner.address)).toString()
  );
  // console.log(
  //   `Quorum from contract: `, await dao.
  // )

  // # Testing the flow of DAO.

  // ## Propose

  // Reward `bob` with 10 tokens
  await await token
    .connect(ram)
    .approve(gitDao.address, ethers.utils.parseEther("20"));
  console.log(`Ram approved 20 new tokens to gitDAO`);
  const encodedFunctionCall = gitDao.interface.encodeFunctionData(
    "buyTokensWithERC20",
    [ram.address, ethers.utils.parseEther("10"), 2, token.address]
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
  console.log("Proposal state", await dao.state(proposalId));

  // Alice wants to vote first.
  const aliceVoteTx = await dao
    .connect(alice)
    .castVoteWithReason(proposalId, 1, "Something else");
  await aliceVoteTx.wait(1);

  // Info about the total votes
  let proposalVotes = await dao.proposalVotes(proposalId);
  console.log(
    `Voting info`,
    proposalVotes[0].toString(),
    proposalVotes[1].toString(),
    proposalVotes[2].toString()
  );
  console.log("Proposal state", await dao.state(proposalId));

  // voting by calling castVoteWithReason
  // const voteTx = await dao.castVoteWithReason(
  //   proposalId,
  //   1,
  //   PROPOSAL_DESCRIPTION
  // );
  // const voteReceipt = await voteTx.wait(1);
  // proposalState = await dao.state(proposalId);
  // console.log(`> Current Proposal State: ${proposalState}`);
  // console.log(`> Reason: ${voteReceipt.events[0].args.reason}`);
  // proposalVotes = await dao.proposalVotes(proposalId);
  console.log(
    `Voting info`,
    proposalVotes[0].toString(),
    proposalVotes[1].toString(),
    proposalVotes[2].toString()
  );

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

  console.log(
    `> Ram owns ${(await token.balanceOf(ram.address)).toString()} new token.`
  );
  console.log(
    `> Ram owns ${(
      await daoToken.balanceOf(ram.address)
    ).toString()} dao token.`
  );
};

main()
  .then((e) => process.exit(0))
  .catch((e) => console.error(e));
