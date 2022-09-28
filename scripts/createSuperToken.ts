import { ethers } from "hardhat";
import { abi as ISuperTokenFactory } from "../artifacts/@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperTokenFactory.sol/ISuperTokenFactory.json";
import { abi as IUUPSProxy } from "../artifacts/contracts/proxy/UUPS.sol/UUPSProxy.json";
import SUPERFLUID_CONFIG from "./config/superfluild";
import { l } from "./core";

const TEST_TOKEN = "0x1163b44a62Bcdb3b98c0aaFc88FB988cfb9A91F1";

(async () => {
  l(
    `Setting up super token factory ${SUPERFLUID_CONFIG.ADDRESS.SUPER_TOKEN_FACTORY}`
  );
  const SuperTokenFactoryProxy = await ethers.getContractAt(
    IUUPSProxy,
    SUPERFLUID_CONFIG.ADDRESS.SUPER_TOKEN_FACTORY_PROXY
  );
  const SuperTokenFactory = await ethers.getContractAt(
    ISuperTokenFactory,
    SUPERFLUID_CONFIG.ADDRESS.SUPER_TOKEN_FACTORY
  );
  l("Setting up test token:", TEST_TOKEN);
  const testToken = await ethers.getContractAt("ERC20Token", TEST_TOKEN);

  l(`Deploying new super token.`);

  await (
    await SuperTokenFactory.createERC20Wrapper(
      TEST_TOKEN,
      await testToken.decimals(),
      2,
      await testToken.name(),
      await testToken.symbol()
    )
  ).wait(1);
  l(`Deployed.`);
})();
