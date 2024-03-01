// added imports for handling address validation
//@todo uncomment
//import { useRouter } from "next/router";
import { Balance } from "../Balance";
import { AddressInfoDropdown } from "./AddressInfoDropdown";
import { AddressQRCodeModal } from "./AddressQRCodeModal";
import { WrongNetworkDropdown } from "./WrongNetworkDropdown";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { Address } from "viem";
import { useAutoConnect, useNetworkColor } from "~~/hooks/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { getBlockExplorerAddressLink } from "~~/utils/scaffold-eth";

//import { validateAddress } from "~~/pages/api/validateAddress";

/**
 * Custom Wagmi Connect Button (watch balance + custom design)
 */
export const RainbowKitCustomConnectButton = () => {
  useAutoConnect();
  const networkColor = useNetworkColor();
  const { targetNetwork } = useTargetNetwork();

  // route to blocked page
  // const router = useRouter();

  // // Function to validate the address by calling your Next.js API route
  // async function validateAddressBeforeConnect(address: string) {
  //   console.log("sending validate api request ", address);
  //   const response = await fetch("/api/validateAddress", {
  //     method: "POST",
  //     headers: {
  //       "Content-Type": "application/json",
  //     },
  //     body: JSON.stringify({ address }), // Sending the address to your API route
  //   });

  //   if (!response.ok) {
  //     throw new Error("Failed to validate address with the API");
  //   }

  //   const data = await response.json(); // The response from your API route
  //   console.log("response: ", data);

  //   // Check the tags for specific conditions
  //   const isBlocked =
  //     data.isMaliciousAddress || data.tags.THEFT || data.tags.CYBERCRIME || data.tags.SANCTIONED || data.tags.BOT;

  //   //return !isBlocked;
  //   if (!isBlocked) {
  //     console.log("not blocked 1");
  //     return true;
  //   } else {
  //     console.log("blocked 2");
  //     router.push("/blocked"); // Redirect to the blocked page if the address is flagged
  //     return false;
  //   } // Return true if the address is safe, false otherwise
  // }

  return (
    <ConnectButton.Custom>
      {({ account, chain, openConnectModal,  mounted }) => {
        const connected = mounted && account && chain;
        const blockExplorerAddressLink = account
          ? getBlockExplorerAddressLink(targetNetwork, account.address)
          : undefined;

        return (
          <>
            {(() => {
              if (!connected) {
                return (
                  <button className="btn btn-primary btn-sm" onClick={openConnectModal} type="button">
                    Connect Wallet
                  </button>
                );
              }

              if (chain.unsupported || chain.id !== targetNetwork.id) {
                return <WrongNetworkDropdown />;
              }
              //@todo uncomment - test await for harpie api call - could use when you click button to harvest tokens so it only runs then.
              // if (connected) {
              //   // As soon as the wallet is connected, validate the address
              //   await validateAddressBeforeConnect(account.address);
              // }

              return (
                <>
                  <div className="flex flex-col items-center mr-1">
                    <Balance address={account.address as Address} className="min-h-0 h-auto" />
                    <span className="text-xs" style={{ color: networkColor }}>
                      {chain.name}
                    </span>
                  </div>
                  <AddressInfoDropdown
                    address={account.address as Address}
                    displayName={account.displayName}
                    ensAvatar={account.ensAvatar}
                    blockExplorerAddressLink={blockExplorerAddressLink}
                  />
                  <AddressQRCodeModal address={account.address as Address} modalId="qrcode-modal" />
                </>
              );
            })()}
          </>
        );
      }}
    </ConnectButton.Custom>
  );
};
