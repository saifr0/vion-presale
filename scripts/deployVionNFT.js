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
  // string memory name,
  // string memory symbol,
  // address owner
  const owner = process.env.OWNER;

  const VionNFT = await hre.ethers.deployContract("VionNFT", [
    "VION Genesis Validator",
    "VION Genesis Validator",
    owner,
  ]);
  await VionNFT.waitForDeployment();
  console.log("VionNFT deployed to:", VionNFT.target);

  await new Promise((resolve) => setTimeout(resolve, 20000));
  verify(VionNFT.target, [
    "VION Genesis Validator",
    "VION Genesis Validator",
    owner,
  ]);
  console.log("Verified..");
}

main();
