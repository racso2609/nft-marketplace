const { expect } = require("chai");
const { fixture } = deployments;
const { printGas } = require("../utils/transactions");

describe("Nft", () => {
  beforeEach(async () => {
    ({ deployer, user, userNotRegister } = await getNamedAccounts());
    userSigner = await ethers.provider.getSigner(user);
    await fixture(["ERC721"]);
    nft = await ethers.getContract("ERC721");
  });
  describe("Initialize contract", () => {
    it("initialize info", async () => {
      const name = await nft.name();
      const symbol = await nft.symbol();
      expect(name).to.be.equal("RACSO");
      expect(symbol).to.be.equal("RAC");
    });
    it("able to mint", async () => {
      const URI = "ipfs://utiiiiti/utitii";
      const tx = await nft.mint(URI);
      await printGas(tx);
      const tokenId = tx.value.toNumber();
      const nftURI = await nft.tokenURI(tokenId);
      expect(nftURI).to.be.eq(URI);
    });
  });
});
