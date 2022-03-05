const { expect } = require("chai");
const { fixture } = deployments;
const { utils } = ethers;
const { printGas } = require("../utils/transactions");

describe("Marketplace", () => {
  beforeEach(async () => {
    ({ deployer, user, userNotRegister } = await getNamedAccounts());
    userSigner = await ethers.provider.getSigner(user);
    await fixture(["Marketplace"]);
    marketplace = await ethers.getContract("Marketplace");
    nft = await ethers.getContract("Nft");
  });
  describe("Initialize contract", () => {
    it("correct erc1155 contrac", async () => {
      const erc1155 = await marketplace.erc1155();
      expect(erc1155).to.be.eq(nft.address);
    });
  });
  describe("Set up admin role", () => {
    it("deployer is an admin", async () => {
      const isAdmin = await marketplace.isAdmin(deployer);
      expect(isAdmin);
    });
    it("deployer can become to admin", async () => {
      const tx = await marketplace.becomeAdmin(user);
      await printGas(tx);
      const isAdmin = await marketplace.isAdmin(user);
      expect(isAdmin);
    });
  });

  describe("taxRate", () => {
    it("fail no admin setting up rate", async () => {
      await expect(marketplace.connect(userSigner).setTaxRate(2)).to.be
        .reverted;
    });
    it("admin can set up rate", async () => {
      const tx = await marketplace.setTaxRate(2);
      await printGas(tx);
      const taxRate = await marketplace.taxRate();
      expect(taxRate).to.be.eq(2);
    });
  });

  describe("recipient", () => {
    it("fail no admin setting up recipient", async () => {
      await expect(marketplace.connect(userSigner).setRecipient(2)).to.be
        .reverted;
    });
    it("admin can set up rate", async () => {
      const tx = await marketplace.setRecipient(deployer);
      await printGas(tx);
      const taxRate = await marketplace.recipient();
      expect(taxRate).to.be.eq(deployer);
    });
  });
});
