// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const SachiToken = await ethers.getContractFactory("SachiToken");
  const TimeLockWalletFactory = await ethers.getContractFactory("TimeLockWalletFactory");
  const TimeLockWallet = await ethers.getContractFactory("TimeLockWallet");

   await (await SachiToken.deploy()).deployed();
  const relayer = '0xF82986F574803dfFd9609BE8b9c7B92f63a1410E';
  const timeLockWallet = await TimeLockWallet.deploy();
  await timeLockWallet.deployed();
  await (await TimeLockWalletFactory.deploy(timeLockWallet.address, relayer)).deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
