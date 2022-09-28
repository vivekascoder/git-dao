import {ethers} from 'hardhat';

(
  async () => {
    const TestDelegateCall = await ethers.getContractFactory("TestDelegateCall");
    const DelegateCall = await ethers.getContractFactory("DelegateCall");

    const testDelegateCall = await TestDelegateCall.deploy();
    const delegateCall = await DelegateCall.deploy();
    
    await (
      await delegateCall.setVars(testDelegateCall.address, 100)
    ).wait(1)
    console.log(`Delegate call done.`)
  }
)()
