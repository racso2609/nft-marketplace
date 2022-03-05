const { expect } = require("chai");
const { fixture } = deployments;
const { printGas } = require("../utils/transactions");

describe("Nft", () => {
  beforeEach(async () => {
    ({ deployer, user, userNotRegister } = await getNamedAccounts());
    userSigner = await ethers.provider.getSigner(user);
    await fixture(["Nft"]);
    nft = await ethers.getContract("Nft");
  });
  describe("Initialize contract", () => {
    it("able to mint", async () => {
      const URI = "ipfs://utiiiiti/utitii";
      const tx = await nft.mint(URI, 10);
      await printGas(tx);
      const tokenId = tx.value.toNumber();
      const nftBalance = await nft.balanceOf(deployer, tokenId);
      const nftURI = await nft.uri(tokenId);
      expect(nftURI).to.be.eq(URI);
      expect(nftBalance).to.be.eq(10);
    });
  });
});
