import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import verify from "../utils";
import { networkConfig, developmentChains } from "../hardhat.config";
import { ethers } from "hardhat";

const deployBox: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  log("----------------------------------------------------");
  log("Deploying Box and waiting for confirmations...");

  const dao = await ethers.getContract("DAO");
  const daoTimelock = await ethers.getContract("DAOTimelock");
  const daoToken = await ethers.getContract("DAOToken");

  const gitDao = await deploy("GitDAO", {
    from: deployer,
    args: [
      dao.address,
      daoTimelock.address,
      daoToken.address,
      "vivekascoder/git-dao",
      "3f3rf3w",
    ],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`Box at ${gitDao.address}`);
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(gitDao.address, []);
  }
  const gitDaoContract = await ethers.getContractAt("GitDAO", gitDao.address);
  const transferTx = await gitDaoContract.transferOwnership(
    daoTimelock.address
  );
  await transferTx.wait(1);
  // Mint into the treasury.
  const setDaoTx = await daoToken.setDaoContract(gitDao.address);
  await setDaoTx.wait(1);
  const mintTx = await daoToken.sendToDAO();
  await mintTx.wait(1);
  console.log(
    `> Treasury Balance: ${await daoToken.balanceOf(gitDao.address)}`
  );
};

export default deployBox;
deployBox.tags = ["all", "GitDAO"];
