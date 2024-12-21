import { ethers } from "hardhat";

async function main() {
  // getting contract
  const TrophyVerification = await ethers.getContractFactory("TrophyVerification");

   // deploying the contract
   console.log("Deploying TrophyVerification...");
   const trophy = await TrophyVerification.deploy();
   await trophy.waitForDeployment();
 
   const address = await trophy.getAddress();
   console.log("TrophyVerification deployed to:", address);
}
