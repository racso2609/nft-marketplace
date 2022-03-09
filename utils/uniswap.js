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
require("dotenv").config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

const chainId = ChainId.RINKEBY;

async function swap({ fundAddress, tokenAddress }) {
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
    "function swapETHForTokens(uint amountOutMin,address[] calldata path,address to,uint deadline) external payable returns (uint[] memory amounts)",
  ];

  const slippageTolerance = new Percent("50", "10000");
  const amountOutMin = trade.minimumAmountOut(slippageTolerance).rawl;
  const path = [weth.address, token.address];
  const deadline = Math.floor(Date.now() / 1000) + 60 * 20;
  const value = trade.inputAmount.raw;
  const signer = await ethers.provider.getSigner(fundAddress);
  console.log("signer");
  const uniswap = new ethers.Contract(
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    abi,
    signer.provider
  );

  console.log("uniswap", uniswap);

  const tx = await uniswap
    .connect(signer)
    .sendExactETHForTokens(amountOutMin, path, "", deadline, {
      value,
      gasPrice: 20e18,
    });
  console.log(tx);
  const receipt = await tx.wait();
  console.log(receipt);
}

async function swap1({ fundAddress, impersonateAddress, tokenAddress }) {
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [impersonateAddress],
  });
  const abi = [
    {
      inputs: [
        {
          internalType: "address",
          name: "src",
          type: "address",
        },
        {
          internalType: "address",
          name: "guy",
          type: "address",
        },
      ],
      name: "allowance",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "guy",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "wad",
          type: "uint256",
        },
      ],
      name: "approve",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "guy",
          type: "address",
        },
      ],
      name: "balanceOf",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "dst",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "wad",
          type: "uint256",
        },
      ],
      name: "transfer",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "src",
          type: "address",
        },
        {
          internalType: "address",
          name: "dst",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "wad",
          type: "uint256",
        },
      ],
      name: "transferFrom",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
  ];

  const signer = await ethers.provider.getSigner(impersonateAddress);
  const tokenContract = new ethers.Contract(tokenAddress, abi, signer.provider);
  const tx = await tokenContract
    .connect(signer)
    .transfer(fundAddress, ethers.utils.parseEther("100"));
  const receipt = await tx.wait();
  console.log(receipt);
}

module.exports = { swap };
