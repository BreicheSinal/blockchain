import { expect } from "chai";
import { ethers } from "hardhat";
import { TrophyVerification } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

// TrophyVerification smart contract test
describe("TrophyVerification", function () {
  // variable holding deployed contract instance
  let trophyVerification: TrophyVerification;

  // represents the owner/deployer of contract
  let owner: SignerWithAddress;

  // represents a user (coach/club/athlete) interacting with the contract
  let user: SignerWithAddress;

  // runs before each test case to deploy a fresh instance of the contract && set up signers
  beforeEach(async function () {
    // retrieving the available Ethereum accounts for testing
    [owner, user] = await ethers.getSigners();

    const TrophyVerification = await ethers.getContractFactory(
      "TrophyVerification"
    );

    // deploying the TrophyVerification contract
    trophyVerification = await TrophyVerification.deploy();
  });

  // group of tests related to trophy requests
  describe("Trophy Request", function () {
    // tests if a user can create a new trophy request && check storage of data
    it("Should create a new trophy request", async function () {
      // user creating a trophy request
      const tx = await trophyVerification
        .connect(user)
        .requestTrophy("Olympic Medal", "Gold medal in 100m sprint");

      // waiting for the transaction to be mined
      const receipt = await tx.wait();

      // retrieving first event emitted
      const event = receipt?.logs[0];

      // asserting an event was emitted
      expect(event).to.exist;

      // retrieving trophy details from contract
      const trophy = await trophyVerification.trophies(0);
      expect(trophy.name).to.equal("Olympic Medal"); // asserting if trophy name matches
      expect(trophy.description).to.equal("Gold medal in 100m sprint"); // asserting if description is correct
      expect(trophy.requester).to.equal(user.address); // asserting if requester is user
      expect(trophy.status).to.equal(0); // asserting if status is 'Pending' == 0
    });
  });
});
