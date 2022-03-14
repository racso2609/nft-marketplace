const { expect } = require("chai");
const { fixture } = deployments;
const { printGas, increaseTime } = require("../utils/transactions");
const { swap, allowance, balanceOf } = require("../utils/uniswap");

describe("Marketplace", () => {
  beforeEach(async () => {
    ({ deployer, user, userNotRegister, feeRecipient } =
      await getNamedAccounts());
    userSigner = await ethers.provider.getSigner(user);
    deployerSigner = await ethers.provider.getSigner(deployer);
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
      priceUSD = 2;
      tokenURI = "ipfs://1234/12323";

      duration = 10 * 60 * 60;
      const tx = await nft.mint(tokenURI, 10);
      await printGas(tx);
    });
    describe("create sell", () => {
      it("unlock for sale fail try list 0 tokens", async () => {
        await expect(
          marketplace.unlockForSale(tokenId, 0, priceUSD, duration)
        ).to.be.revertedWith("You cant sell 0 tokens!");
      });
      it("unlock for sale fail you dont have enought tokens", async () => {
        await expect(
          marketplace.unlockForSale(tokenId, amount + 1, priceUSD, duration)
        ).to.be.revertedWith("You dont have enought tokens!");
      });
      it("unlock for sale", async () => {
        const tx = await marketplace.unlockForSale(
          tokenId,
          amount,
          priceUSD,
          duration
        );
        await printGas(tx);
        const sellId = tx.value;
        const newSell = await marketplace.sales(sellId);

        expect(newSell.tokenId).to.be.eq(tokenId);
        expect(newSell.amount).to.be.eq(amount);
        expect(newSell.priceUSD).to.be.eq(priceUSD);
        expect(newSell.owner).to.be.eq(deployer);
        expect(newSell.duration).to.be.eq(duration);
      });
      it("cancel sale", async () => {
        const createSaleTx = await marketplace.unlockForSale(
          tokenId,
          amount,
          priceUSD,
          duration
        );
        await printGas(createSaleTx);

        let mySale = await marketplace.sales(0);
        const tx = await marketplace.cancelSale(0);
        await printGas(tx);
        mySale = await marketplace.sales(0);
        expect(mySale.cancelled);
      });
    });
  });

  describe("buy", () => {
    beforeEach(async () => {
      priceUSD = 1;

      daiAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

      linkAddress = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
      const tx = await nft.connect(userSigner).mint(tokenURI, 10);
      await printGas(tx);
      await swap({
        tokenAddress: daiAddress,
        fundAddress: deployer,
        impersonateAddress: "0x7879a0c239f33db9160a8036db0e082616ca8690",
        contractAddress: marketplace.address,
      });

      await swap({
        tokenAddress: linkAddress,
        fundAddress: deployer,
        impersonateAddress: "0x5a52e96bacdabb82fd05763e25335261b270efcb",
      });
    });

    describe("eth", () => {
      beforeEach(async () => {
        const tx = await marketplace
          .connect(userSigner)
          .unlockForSale(tokenId, amount, priceUSD, duration);
        await printGas(tx);
        sellId = tx.value;
      });
      it("fail trying to buy not enought eth send ", async () => {
        await expect(marketplace.buyEth(0)).to.be.revertedWith(
          "Incorrect amount"
        );
      });
      it("buy", async () => {
        const tx = await marketplace.buyEth(0, {
          value: ethers.utils.parseEther("1"),
        });
        await printGas(tx);
        const sell = await marketplace.sales(sellId);
        expect(sell.sold);
      });
      it("test buy event", async () => {
        await expect(
          marketplace.buyEth(0, {
            value: ethers.utils.parseEther("1"),
          })
        )
          .to.emit(marketplace, "Buy")
          .withArgs(0, deployer, user);
      });
      it("try to buy sold Token", async () => {
        const tx = await marketplace.buyEth(0, {
          value: ethers.utils.parseEther("1"),
        });
        await printGas(tx);
        await expect(marketplace.buyEth(0)).to.be.revertedWith("Tokens solds!");
      });
      it("try to buy expired token", async () => {
        await increaseTime(duration + 10);
        await expect(marketplace.buyEth(0)).to.be.revertedWith(
          "Deadline reached!"
        );
      });
      it("try to buy cancelled tokens", async () => {
        await marketplace.connect(userSigner).cancelSale(0);
        await expect(marketplace.buyEth(0)).to.be.revertedWith(
          "Sale cancelled!"
        );
      });
    });
    describe("DAI", () => {
      beforeEach(async () => {
        const tx = await marketplace
          .connect(userSigner)
          .unlockForSale(tokenId, amount, priceUSD, duration);
        await printGas(tx);
        sellId = tx.value;

        const balance = await balanceOf({
          tokenAddress: daiAddress,
          userAddress: deployer,
        });
        console.log(balance.toString());
      });

      it("insufficient allowance", async () => {
        await expect(marketplace.buyDai(0)).to.be.revertedWith(
          "Dai/insufficient-allowance"
        );
      });
      it("buy", async () => {
        await allowance({
          fundAddress: deployer,
          contractAddress: marketplace.address,
          amount: ethers.BigNumber.from("10000000000000"),
          tokenAddress: daiAddress,
        });
        const tx = await marketplace.buyDai(0);

        await printGas(tx);
        const sell = await marketplace.sales(sellId);
        expect(sell.sold);
        expect(
          await balanceOf({
            tokenAddress: daiAddress,
            userAddress: feeRecipient,
          })
        ).be.gt(0);
      });
      it("buy event", async () => {
        await allowance({
          fundAddress: deployer,
          contractAddress: marketplace.address,
          tokenAddress: daiAddress,
          amount: ethers.BigNumber.from("10000000000000"),
        });
        await expect(marketplace.buyDai(0))
          .to.emit(marketplace, "Buy")
          .withArgs(0, deployer, user);
      });
    });
    describe("Link", () => {
      beforeEach(async () => {
        const tx = await marketplace
          .connect(userSigner)
          .unlockForSale(tokenId, amount, priceUSD, duration);
        await printGas(tx);
        sellId = tx.value;
        const balance = await balanceOf({
          tokenAddress: linkAddress,
          userAddress: deployer,
        });
      });

      it("insufficient allowance", async () => {
        await expect(marketplace.buyLink(0)).to.be.reverted;
      });
      it("buy", async () => {
        await allowance({
          fundAddress: deployer,
          contractAddress: marketplace.address,
          tokenAddress: linkAddress,
          amount: ethers.BigNumber.from("10000000000000"),
        });
        const tx = await marketplace.buyLink(0);

        await printGas(tx);
        const sell = await marketplace.sales(sellId);
        expect(sell.sold);
        expect(
          await balanceOf({
            tokenAddress: linkAddress,
            userAddress: feeRecipient,
          })
        ).be.gt(0);
      });
      it("buy event", async () => {
        await allowance({
          fundAddress: deployer,
          contractAddress: marketplace.address,
          tokenAddress: linkAddress,
          amount: ethers.BigNumber.from("10000000000000"),
        });
        await expect(marketplace.buyLink(0))
          .to.emit(marketplace, "Buy")
          .withArgs(0, deployer, user);
      });
    });
  });
});
