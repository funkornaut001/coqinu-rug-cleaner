import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployMocksAndCoqInuRugCleaner: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  // Deploy Mock ERC20 Token
  const mockERC20Deployment = await deploy("MockERC20", {
    from: deployer,
    args: ["MockCoq", "MCQ"],
    log: true,
  });
  console.log(`MockERC20 deployed to: ${mockERC20Deployment.address}`);

  // Deploy Mock ERC721 Token
  const mockERC721Deployment = await deploy("MockERC721", {
    from: deployer,
    args: ["MockNFT", "MNFT"],
    log: true,
  });
  console.log(`MockERC721 deployed to: ${mockERC721Deployment.address}`);

  // Deploy Mock ERC1155 Token
  const mockERC1155Deployment = await deploy("MockERC1155", {
    from: deployer,
    log: true,
  });
  console.log(`MockERC1155 deployed to: ${mockERC1155Deployment.address}`);

  // Deploy CoqInuRugCleaner Contract
  const coqInuRugCleanerDeployment = await deploy("CoqInuRugCleaner", {
    from: deployer,
    args: ["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", mockERC20Deployment.address],
    log: true,
  });
  console.log(`CoqInuRugCleaner deployed to: ${coqInuRugCleanerDeployment.address}`);
};

export default deployMocksAndCoqInuRugCleaner;
deployMocksAndCoqInuRugCleaner.tags = ["MocksAndCoqInuRugCleaner"];
