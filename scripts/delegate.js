const hre = require("hardhat");

async function main() {
  const [delegator] = await hre.ethers.getSigners();

  console.log("Delegating voting power from:", delegator.address);

  const tokenAddress = "0x4354Ad0d942e2D80f6ce25Cb00A2d2B8dCF6116a";

  const Token = await hre.ethers.getContractAt(
    "AlkebulanCash",
    tokenAddress
  );

  const tx = await Token.delegate(delegator.address);
  await tx.wait();

  console.log("Delegation successful.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});