import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import verify from "../utils";
import { networkConfig, developmentChains } from "../hardhat.config";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

const deployDAOFactory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  // @ts-ignore
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log("----------------------------------------------------");
  log("Deploying the CreateDAOToken");
  const createDaoToken = await deploy("CreateDAOToken", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`CreateDAOToken at ${createDaoToken.address}`);

  log("Deploying CreateDAO contract");
  const createDao = await deploy("CreateDAO", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`CreateDAO at ${createDao.address}`);

  log("Deploying DAOFactory");
  const daoFactory = await deploy("DAOFactory", {
    from: deployer,
    args: [deployer, createDaoToken.address, createDao.address],
    waitConfirmations: networkConfig[network.name].blockConfirmations || 1,
  });
  log(`DAOFactory at ${daoFactory.address}`);

  // Verify on etherscan
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(createDaoToken.address, []);
    await verify(createDao.address, []);
    await verify(daoFactory.address, []);
  }
};

export default deployDAOFactory;
deployDAOFactory.tags = ["all", "governor factory"];
