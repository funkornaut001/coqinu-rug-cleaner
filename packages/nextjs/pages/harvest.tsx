import React from "react";
import HarvestERC20 from "~~/components/Harvest20";
import HarvestERC721 from "~~/components/Harvest721";
import HarvestERC1155 from "~~/components/Harvest1155";

const HarvestErc721Page = () => {
  return (
    <div>
      <HarvestERC721 />
      <HarvestERC20 />
      <HarvestERC1155 />
      {/* You can add more content or styling as needed */}
    </div>
  );
};

export default HarvestErc721Page;
