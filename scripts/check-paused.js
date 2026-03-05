const hre = require("hardhat");

async function main() {
  const tokenAddress = "0x516027b80186f033E99B1dFaF325C8848A585196";

  const Token = await hre.ethers.getContractAt(
    "AlkebulanCash",
    tokenAddress
  );

  const paused = await Token.paused();
  console.log("Token paused?", paused);
}

main().catch(console.error);