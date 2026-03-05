const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying Governor with account:", deployer.address);

  // AKBC token address (Sepolia)
  const tokenAddress = "0x4354Ad0d942e2D80f6ce25Cb00A2d2B8dCF6116a";

  const Token = await hre.ethers.getContractAt(
    "AlkebulanCash",
    tokenAddress
  );

  const Governor = await hre.ethers.getContractFactory("AKBCGovernor");
  const governor = await Governor.deploy(Token.target);

  await governor.waitForDeployment();

  console.log("AKBCGovernor deployed to:", governor.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});