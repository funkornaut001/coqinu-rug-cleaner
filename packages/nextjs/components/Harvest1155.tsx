import React, { useState } from "react";
import { useContractWrite } from "wagmi";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";

// eslint-disable-line import/no-unresolved

const HarvestERC1155 = () => {
  const [tokenAddress, setTokenAddress] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [amount, setAmount] = useState("");
  const [isApproved, setIsApproved] = useState(false);


  const { data: harvester } = useDeployedContractInfo("Harvester");
  const { data: mock1155 } = useDeployedContractInfo("MockERC1155");

  const {
    write: approveWrite,
    isLoading: isApproveLoading,
    isSuccess: isApproveSuccess,
    isError: isApproveError,
  } = useContractWrite({
    address: tokenAddress, // The ERC-1155 token contract address
    abi: mock1155?.abi,
    functionName: "setApprovalForAll",
    args: [harvester?.address, true],
  });

  // Set up your contract write interaction
   const {
    write: harvestWrite,
    isLoading: isHarvestLoading,
    isSuccess: isHarvestSuccess,
    isError: isHarvestError,
  } = useContractWrite({
    address: harvester?.address,
    abi: harvester?.abi,
    functionName: "harvestERC1155",
    args: [tokenAddress, BigInt(tokenId), BigInt(amount)],
    value: BigInt(690000000000000),
    // Add overrides if you need to send value or set gas limit
  });

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
      <h1 className="text-xl font-bold mb-4 text-primary">Harvest ERC-1155 Tokens</h1>
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
          value={tokenId}
          onChange={e => setTokenId(e.target.value)}
          placeholder="Token ID"
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
          Harvest ERC-1155 Tokens
        </button>
      )}
      {isSuccess && <p className="mt-2 text-success">Token harvested successfully!</p>}
      {isError && <p className="mt-2 text-error">There was an error harvesting the token.</p>}
    </div>
  );
};
export default HarvestERC1155;
