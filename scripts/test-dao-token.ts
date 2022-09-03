import { ethers } from "hardhat";

(async () => {
  const [owner, dao] = await ethers.getSigners();
  const Token = await ethers.getContractFactory("DAOToken");
  const token = await Token.connect(owner).deploy(
    "Super Token",
    "ST",
    ethers.utils.parseEther("10000"),
    20
  );
  console.log(`> Deployed address: ${token.address}`);

  // Check the admin.
  console.log(`> Current admin: ${await token.owner()}`);
  console.log(`> Expected owner: ${owner.address}`);

  // Set the dao.
  await (await token.setDaoContract(dao.address)).wait(1);

  console.log(`> Balance Before: ${await token.balanceOf(dao.address)}`);

  // Mint tokens for the dao treasury.
  await (await token.sendToDAO()).wait(1);

  // Check the balance of treasury.
  console.log(`> Balance After: ${await token.balanceOf(dao.address)}`);
})();
