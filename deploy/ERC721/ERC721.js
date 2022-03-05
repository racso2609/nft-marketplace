const CONTRACT_NAME = "ERC721";
const TOKEN_NAME = "RACSO";
const TOKEN_SYMBOL = "RAC";

// modify when needed
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Upgradeable Proxy
  await deploy(CONTRACT_NAME, {
    from: deployer,
    log: true,
    proxy: {
      owner: deployer,
      init: {
        methodName: "initialize",
        args: [TOKEN_NAME, TOKEN_SYMBOL],
      },
    },
  });
};

module.exports.tags = [CONTRACT_NAME, "ERC721"];
