const CONTRACT_NAME = "Nft";

// modify when needed
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Upgradeable Proxy
  await deploy(CONTRACT_NAME, {
    from: deployer,
    log: true,
  });
};

module.exports.tags = [CONTRACT_NAME, "ERC1155", "Marketplace"];
