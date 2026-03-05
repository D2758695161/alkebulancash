const hre = require("hardhat");

async function main() {
  const [user] = await hre.ethers.getSigners();

  const tokenAddress = "0x516027b80186f033E99B1dFaF325C8848A585196";

  const Token = await hre.ethers.getContractAt(
    "AlkebulanCash",
    tokenAddress
  );

  const ADMIN_ROLE = await Token.ADMIN_ROLE();

  const hasAdmin = await Token.hasRole(ADMIN_ROLE, user.address);

  console.log("Address:", user.address);
  console.log("Has ADMIN_ROLE?", hasAdmin);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});