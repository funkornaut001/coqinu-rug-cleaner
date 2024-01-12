import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployCoqInuRugCleaner: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Deploy to Fuji
  const coqInuRugCleanerDeployment = await deploy("CoqInuRugCleaner", {
    from: deployer,
    args: ["0x9768818565ED5968fAACC6F66ca02CBf2785dB84", "0x420FcA0121DC28039145009570975747295f2329"],
    log: true,
  });
  console.log(`CoqInuRugCleaner deployed to: ${coqInuRugCleanerDeployment.address}`);
};

export default deployCoqInuRugCleaner;
deployCoqInuRugCleaner.tags = ["fuji"];
