const { expect } = require("chai");
const { fixture } = deployments;
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
  describe("Sell", () => {
    beforeEach(async () => {
      tokenId = 0;
      amount = 10;
      priceUSD = 10;
      tokenURI = "ipfs://1234/12323";
      const tx = await nft.mint(tokenURI, 10);
      await printGas(tx);
    });
    describe("create sell", () => {
      it("unlock for sale fail try list 0 tokens", async () => {
        await expect(
          marketplace.unlockForSale(tokenId, 0, priceUSD)
        ).to.be.revertedWith("You cant sell 0 tokens!");
      });
      it("unlock for sale fail you dont have enought tokens", async () => {
        await expect(
          marketplace.unlockForSale(tokenId, amount + 1, priceUSD)
        ).to.be.revertedWith("You dont have enought tokens!");
      });
      it("unlock for sale", async () => {
        const tx = await marketplace.unlockForSale(tokenId, amount, priceUSD);
        await printGas(tx);
        const sellId = tx.value;
        const newSell = await marketplace.sells(sellId);

        expect(newSell.tokenId).to.be.eq(tokenId);
        expect(newSell.amount).to.be.eq(amount);
        expect(newSell.priceUSD).to.be.eq(priceUSD);
      });
    });
    describe("buy", () => {
      beforeEach(async () => {
        const tx = await marketplace.unlockForSale(tokenId, amount, priceUSD);
        await printGas(tx);
        sellId = tx.value;
      });
      describe("eth", () => {
        beforeEach(async () => {
          paymentMethod = "eth";
        });

        it("fail trying to buy not enought token on seller address", () => {});
        it("fail trying to buy for less than the avaliable price", () => {});
        it("buy", () => {});
        it("buy sending more thant the price", () => {});
      });
    });
  });
});
