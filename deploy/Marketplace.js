const CONTRACT_NAME = "Marketplace";
const TAX_RATE = 1;

// modify when needed
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer, feeRecipient } = await getNamedAccounts();

  const Nft = await deployments.get("Nft");

  // Upgradeable Proxy
  await deploy(CONTRACT_NAME, {
    from: deployer,
    log: true,
    proxy: {
      execute: {
        init: {
          methodName: "initialize",
          args: [Nft.address, TAX_RATE, feeRecipient],
        },
      },
    },
  });
};

module.exports.tags = [CONTRACT_NAME, "Marketplace"];
module.exports.dependencies = ["Nft"];
