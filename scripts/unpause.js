const hre = require("hardhat");

async function main() {
  const [admin] = await hre.ethers.getSigners();

  console.log("Unpausing token with account:", admin.address);

  const tokenAddress = "0x516027b80186f033E99B1dFaF325C8848A585196";

  const Token = await hre.ethers.getContractAt(
    "AlkebulanCash",
    tokenAddress
  );

  const tx = await Token.unpause();
  await tx.wait();

  console.log("✅ Token successfully unpaused");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});