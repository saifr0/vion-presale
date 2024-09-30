const hre = require("hardhat");
const { run } = require("hardhat");

async function verify(address, constructorArguments) {
  console.log(
    `verify  ${address} with arguments ${constructorArguments.join(",")}`
  );
  await run("verify:verify", {
    address,
    constructorArguments,
  });
}
async function main() {
  const owner = process.env.OWNER;
  const usdt = "0x6fea2f1b82afc40030520a6c49b0d3b652a65915";
  const vionft = "0xB3B0eC04Dfb1521f8Daaf14462e78b2255d45260";
  const pricefeed = "0x694aa1769357215de4fac081bf1f309adc325306";

  const VionNFT = await hre.ethers.deployContract("VionNFTPresale", [
    usdt,
    vionft,
    pricefeed,
    owner,
    owner,
  ]);
  await VionNFT.waitForDeployment();
  console.log("VionNFT deployed to:", VionNFT.target);

  await new Promise((resolve) => setTimeout(resolve, 30000));
  console.log("Verifying..");
  verify(VionNFT.target, [usdt, vionft, pricefeed, owner, owner]);
}

main();
