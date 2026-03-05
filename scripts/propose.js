const { ethers } = require("hardhat");

async function main() {
  const governorAddress = "0x6DE42b86C200Cf269f1cc291de52fD159FCFB1bD";

  const [proposer] = await ethers.getSigners();
  console.log("Proposer address:", proposer.address);

  const governor = await ethers.getContractAt(
    "AKBCGovernor",
    governorAddress
  );

  // ✅ SAFE TEST PROPOSAL
  const targets = [governorAddress];
  const values = [0];
  const calldatas = ["0x"];
  const description = "Test Proposal: Activate AKBC Governance";

  const tx = await governor.propose(
    targets,
    values,
    calldatas,
    description
  );

  console.log("Proposal transaction sent...");
  const receipt = await tx.wait();

  const proposalId = receipt.logs
    .find(log => log.fragment?.name === "ProposalCreated")
    .args.proposalId;

  console.log("Proposal created successfully!");
  console.log("Proposal ID:", proposalId.toString());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});