import { ethers } from "hardhat";
import {
  developmentChains,
  VOTING_DELAY,
  VOTING_PERIOD,
  MIN_DELAY,
  QUORUM_PERCENTAGE,
} from "../hardhat.config";

async function main() {
  const daoFactory = await ethers.getContract("DAOFactory");
  console.log("Dao FActory Admin", await daoFactory.admin());

  // Deploy new DAO
  const tx = await daoFactory.createDAO(
    "My Awesome DAO",
    "MAD",
    ethers.utils.parseEther("1"),
    20,
    MIN_DELAY,
    QUORUM_PERCENTAGE,
    VOTING_PERIOD,
    VOTING_DELAY,
    "vivekascoder/git-dao",
    "3d3r3"
  );
  await tx.wait(1);
  console.log("Deployed.");
}

main()
  .then(() => process.exit(0))
  .catch((e) => console.error(e));
