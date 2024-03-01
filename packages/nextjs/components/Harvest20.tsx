import React, { useState } from "react";
import { useContractWrite } from "wagmi";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";

// eslint-disable-line import/no-unresolved

const HarvestERC20 = () => {
  const [tokenAddress, setTokenAddress] = useState("");
  const [amount, setAmount] = useState("");
  const [isApproved, setIsApproved] = useState(false);

  const { data: harvester } = useDeployedContractInfo("Harvester");
  const { data: mock20 } = useDeployedContractInfo("MockERC20");

  // Assuming `deployedContract` and `tokenAddress` are defined correctly
  const tokenApprovalArgs = {
    address: tokenAddress, // The ERC-20 token contract address
    abi: mock20?.abi,
    functionName: "approve",

    args: [harvester?.address, BigInt(amount)], // Convert amount to BigNumber with 18 decimals
  };

  const tokenHarvestArgs = {
    address: harvester?.address, // Your contract that requires token approval
    abi: harvester?.abi, // ABI of your contract
    functionName: "harvestERC20",
    args: [tokenAddress, BigInt(amount)], // Assuming `amount` is a string or number representing the token amount
    value: BigInt(690000000000000), //ethers.utils.parseEther("0.00069"), // Convert ETH value to BigNumber
  };

  // Use `useContractWrite` for token approval
  const {
    write: approveWrite,
    isLoading: isApproveLoading,
    isSuccess: isApproveSuccess,
    isError: isApproveError,
  } = useContractWrite(tokenApprovalArgs);

  // Use `useContractWrite` for harvesting tokens
  const {
    write: harvestWrite,
    isLoading: isHarvestLoading,
    isSuccess: isHarvestSuccess,
    isError: isHarvestError,
  } = useContractWrite(tokenHarvestArgs);

  // old way of doing transactions

  // Set up your contract write interaction
  // const { writeHarvest, isHarvestLoading, isHarvestSuccess, isHarvestError } = useContractWrite({
  //   address: deployedContract?.address,
  //   abi: deployedContract?.abi,
  //   functionName: "harvestERC20",
  //   args: [tokenAddress, BigInt(amount)],
  //   value: BigInt(690000000000000),
  //   // Add overrides if you need to send value or set gas limit
  // });

  // //set approvals for tokens
  // const { write, isLoading, isSuccess, isError } = useContractWrite({
  //   address: tokenAddress,
  //   abi: ["approve(address,uint256)"],
  //   functionName: "approve",
  //   args: [deployedContract?.address, BigInt(amount)],
  // });

  // const { data: writeContractResult, writeAsync: approveAsync, error } = useContractWrite(config);

  // // Call the write function when the user submits the form
  // const harvestToken = async () => {
  //   await approveWrite();
  //   harvestWrite();
  // };

  const handleApprove = async () => {
    try {
      // Call the approve function and wait for it to complete
      await approveWrite();
      // Once approved, update state to reflect this
      setIsApproved(true);
    } catch (error) {
      console.error("Approval failed", error);
    }
  };

  const handleHarvest = async () => {
    try {
      // Call the harvest function
      await harvestWrite();
      // Handle post-harvest logic here (e.g., showing a success message)
    } catch (error) {
      console.error("Harvesting failed", error);
    }
  };

  // You can use isLoading, isSuccess, and isError to provide user feedback
  const isLoading = isApproveLoading || isHarvestLoading;
  const isSuccess = isApproveSuccess && isHarvestSuccess;
  const isError = isApproveError || isHarvestError;

  return (
    <div className="p-4 shadow-lg rounded-lg bg-base-100 max-w-md mx-auto">
      <h1 className="text-xl font-bold mb-4 text-primary">Harvest ERC-20 Tokens</h1>
      <div className="mb-4">
        <input
          type="text"
          value={tokenAddress}
          onChange={e => setTokenAddress(e.target.value)}
          placeholder="Token Address"
          className="input input-bordered w-full"
        />
      </div>
      <div className="mb-4">
        <input
          type="text"
          value={amount}
          onChange={e => setAmount(e.target.value)}
          placeholder="Amount to harvest"
          className="input input-bordered w-full"
        />
      </div>
      {!isApproved ? (
        <button
          onClick={handleApprove}
          disabled={isLoading}
          className={`btn btn-primary w-full ${isLoading ? "loading" : ""}`}
        >
          Approve Tokens
        </button>
      ) : (
        <button
          onClick={handleHarvest}
          disabled={isLoading}
          className={`btn btn-primary w-full ${isLoading ? "loading" : ""}`}
        >
          Harvest Tokens
        </button>
      )}

      {isSuccess && <p className="mt-2 text-success">Token harvested successfully!</p>}
      {isError && <p className="mt-2 text-error">There was an error harvesting the token.</p>}
    </div>
  );
};

export default HarvestERC20;
