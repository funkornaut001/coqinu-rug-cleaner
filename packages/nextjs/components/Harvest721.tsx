import React, { useState } from "react";
import { useContractWrite } from "wagmi";
import { useDeployedContractInfo } from "~~/hooks/scaffold-eth";

// eslint-disable-line import/no-unresolved

const HarvestERC721 = () => {
  const [tokenAddress, setTokenAddress] = useState("");
  const [tokenId, setTokenId] = useState("");

  //const tokenIdBigInt = BigInt(tokenId);

  const { data: deployedContract } = useDeployedContractInfo("Harvester");

  // Set up your contract write interaction
  const { write, isLoading, isSuccess, isError } = useContractWrite({
    address: deployedContract?.address,
    abi: deployedContract?.abi,
    functionName: "harvestERC721",
    args: [tokenAddress, BigInt(tokenId)],
    value: BigInt(6900000000000000),
    // Add overrides if you need to send value or set gas limit
  });

  // Call the write function when the user submits the form
  const harvestToken = () => {
    write();
  };

  // You can use isLoading, isSuccess, and isError to provide user feedback

  return (
    <div className="p-4 shadow-lg rounded-lg bg-base-100 max-w-md mx-auto">
      <h1 className="text-xl font-bold mb-4 text-primary">Harvest ERC-721 Token</h1>
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
      <button
        onClick={harvestToken}
        disabled={isLoading}
        className={`btn btn-primary w-full ${isLoading ? "loading" : ""}`}
      >
        Harvest ERC-721 Token
      </button>
      {isSuccess && <p className="mt-2 text-success">Token harvested successfully!</p>}
      {isError && <p className="mt-2 text-error">There was an error harvesting the token.</p>}
    </div>
  );
};
export default HarvestERC721;
