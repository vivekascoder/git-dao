import { ethers } from "hardhat";

(async () => {
  // Test test sol
  const A = await ethers.getContractFactory("A");
  const CreateAContract = await ethers.getContractFactory("CreateAContract");
  const AFactory = await ethers.getContractFactory("AFactory");

  //   Deploy the contracts
  const createA = await CreateAContract.deploy();
  const afactory = await AFactory.deploy(createA.address);

  // Call
  await (await afactory.createA(100)).wait(1);
  console.log(`A.value: `, await afactory.getA());
})();
