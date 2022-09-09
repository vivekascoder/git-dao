import { ethers } from "hardhat";

(async () => {
  const [owner] = await ethers.getSigners();
  const token = await ethers.getContractAt(
    "DAOToken",
    "0x94CF7F5188b98577D4239697a3A30Cb4CdAB1B1f"
  );

  await (
    await token.transfer(
      "0xdB11f9D4D5394F131B8E30F9ec15C5d71d634DBf",
      ethers.utils.parseEther("50000")
    )
  ).wait(1);
  console.log(
    "Balance of new user, ",
    (
      await token.balanceOf("0xdB11f9D4D5394F131B8E30F9ec15C5d71d634DBf")
    ).toString()
  );
})();
