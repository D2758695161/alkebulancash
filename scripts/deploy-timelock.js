const { ethers } = require("hardhat");

async function main() {

  const [deployer] = await ethers.getSigners();

  console.log("Deploying Timelock with account:", deployer.address);

  const minDelay = 3600; // 1 hour delay

  const governorAddress = "0x6DE42b86C200Cf269f1cc291de52fD159FCFB1bD";

  const proposers = [governorAddress];

  const executors = [
    "0x0000000000000000000000000000000000000000"
  ]; // anyone can execute

  const Timelock = await ethers.getContractFactory("AKBCTimelock");

  const timelock = await Timelock.deploy(
    minDelay,
    proposers,
    executors
  );

  await timelock.waitForDeployment();

  const address = await timelock.getAddress();

  console.log("Timelock deployed to:", address);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});