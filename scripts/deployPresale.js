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
  const vionft = "0xa9Fad93F67f287d3F7096f644e347453e751e96a";
  const pricefeed = "0x694aa1769357215de4fac081bf1f309adc325306";

  //   const VionNFT = await hre.ethers.deployContract("VionNFTPresale", [
  //     usdt,
  //     vionft,
  //     pricefeed,
  //     owner,
  //     owner,
  //   ]);
  //   await VionNFT.waitForDeployment();
  //   console.log("VionNFT deployed to:", VionNFT.target);

  //   await new Promise((resolve) => setTimeout(resolve, 20000));
  verify("0xD05694A07a5C329fcac38DCF03507aFdf9aA90cc", [
    usdt,
    vionft,
    pricefeed,
    owner,
    owner,
  ]);
  console.log("Verified..");
}

main();
