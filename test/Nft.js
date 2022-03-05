const { expect } = require("chai");
const { fixture } = deployments;
const { utils } = ethers;

describe("Nft", () => {
  beforeEach(async () => {
    ({ deployer, user, userNotRegister } = await getNamedAccounts());
    userSigner = await ethers.provider.getSigner(user);
    await fixture(["Nft"]);
    nft = ethers.getContract("Nft");
  });
  describe("Initialize contract", () => {
    it("initialize info", async () => {
      expect(nft.name).to.be.equal("RACSO");
      expect(nft.symbol).to.be.equal("RAC");
    });
  });
});
