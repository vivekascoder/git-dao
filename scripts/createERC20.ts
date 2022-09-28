import { l } from "./core";
import { ethers } from "hardhat";

(async () => {
  const ERC20 = await ethers.getContractFactory("ERC20Token");
  const erc20 = await ERC20.deploy(
    "Test Token",
    "TEST",
    ethers.utils.parseEther("1000")
  );
  l(`ERC20 Address: ${erc20.address}`);
})();
