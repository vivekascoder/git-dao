import { ethers } from "hardhat";

(async () => {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.ALCHEMY_POLYGON_TESTNET
  );
})();
