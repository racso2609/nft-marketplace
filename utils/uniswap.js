const {
  ChainId,
  Fetcher,
  WETH,
  Route,
  Trade,
  TokenAmount,
  TradeType,
  Percent,
} = require("@uniswap/sdk");
const { ethers } = require("ethers");
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

const chainId = ChainId.MAINNET;

async function swap({ fundAddress, impersonateAddress, tokenAddress }) {
  const token = await Fetcher.fetchTokenData(chainId, tokenAddress);
  const weth = WETH[chainId];
  const pair = await Fetcher.fetchPairData(token, weth);
  const route = new Route([pair], weth);
  const trade = new Trade(
    route,
    new TokenAmount(weth, "100000000000000000"),
    TradeType.EXACT_INPUT
  );
  const abi = [
    "function swapETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external override payable ensure(deadline) returns (uint[] memory amounts)",
  ];

  const slippageTolerance = new Percent("50", "10000");
  const amountOutMin = trade.minimumAmountOut(slippageTolerance).rawl;
  const path = [weth.address, tokenAddress];
  const deadline = Math.floor(Date.now() / 1000) + 60 * 20;
  const value = trade.inputAmount.raw;
  const signer = ethers.getSigner(fundAddress);
  const uniswap = await ethers.Contract(
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    abi
  );

  const tx = await uniswap
    .connect(signer)
    .sendExactETHForTokens(amountOutMin, path, fundAddress, deadline, {
      value,
      gasPrice: 20e18,
    });
  const receipt = await tx.wait();
  console.log(receipt);
}
module.exports = { swap };
