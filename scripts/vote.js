const { ethers } = require("hardhat");

async function main() {
  const governorAddress = "0x6DE42b86C200Cf269f1cc291de52fD159FCFB1bD";
  const proposalId =
    "57775380730756975463211671391587181496889299595535848353116974098540162147534";

  const [voter] = await ethers.getSigners();
  console.log("Voter address:", voter.address);

  const governor = await ethers.getContractAt(
    "AKBCGovernor",
    governorAddress
  );

  /**
   * Vote types:
   * 0 = Against
   * 1 = For
   * 2 = Abstain
   */
  const voteType = 1; // ✅ FOR

  const tx = await governor.castVote(proposalId, voteType);
  console.log("Vote transaction sent...");

  await tx.wait();
  console.log("✅ Vote cast successfully!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});