require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.25",
      },
    ],
  },
  networks: {
    mainnet: {
      url: process.env.URL_MAIN,
      accounts: [process.env.PRIVATE_KEY_MAIN],
      chainId: 1,
    },
    sepolia: {
      url: process.env.URL_SEPOLIA,
      accounts: [process.env.PRIVATE_KEY_SEPOLIA],
    },
  },
  etherscan: {
    apiKey: process.env.API_KEY,
  },
};
