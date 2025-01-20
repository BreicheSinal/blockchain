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

  // group of tests related to trophy verification
  describe("Trophy Verification", function () {
    // trophy request is created by user before each test
    beforeEach(async function () {
      await trophyVerification
        .connect(user)
        .requestTrophy("Olympic Medal", "Gold medal in 100m sprint");
    });

    // testing federation (owner) can verify a trophy request
    it("Should allow federation to verify trophy", async function () {
      // federation verifies trophy
      await trophyVerification.verifyTrophy(0, true);

      // retrieving updated trophy details.
      const trophy = await trophyVerification.trophies(0);
      expect(trophy.status).to.equal(1); // asserting if status is 'Verified' == 1
    });

    // testing that a non-federation user cannot verify a trophy
    it("Should not allow non-federation to verify trophy", async function () {
      // user attempting to verify the trophy
      await expect(
        trophyVerification.connect(user).verifyTrophy(0, true)
      ).to.be.revertedWithCustomError(trophyVerification, "OnlyFederation"); // asserting if transaction is reverted with expected custom error
    });
  });
});
