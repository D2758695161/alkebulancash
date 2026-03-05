async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying with account:", deployer.address);
  console.log(
    "Account balance:",
    (await deployer.provider.getBalance(deployer.address)).toString()
  );

  // 1. Deploy GasTreasury
  const GasTreasury = await ethers.getContractFactory("GasTreasury");
  const gasTreasury = await GasTreasury.deploy(deployer.address);
  await gasTreasury.waitForDeployment();

  const gasTreasuryAddress = await gasTreasury.getAddress();
  console.log("GasTreasury deployed to:", gasTreasuryAddress);

  // 2. Deploy AlkebulanCash
  const AlkebulanCash = await ethers.getContractFactory("AlkebulanCash");
  const akb = await AlkebulanCash.deploy();
  await akb.waitForDeployment();

  const akbAddress = await akb.getAddress();
  console.log("AlkebulanCash deployed to:", akbAddress);

  // 3. Initialize AlkebulanCash
  const tx = await akb.initialize(gasTreasuryAddress);
  await tx.wait();

  console.log("AlkebulanCash initialized");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});