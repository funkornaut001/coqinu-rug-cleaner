import React from "react";
import Link from "next/link";
import type { NextPage } from "next";
//import { CurrencyDollarIcon, PuzzlePieceIcon, TicketIcon } from "@heroicons/react/24/outline";
//import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      {/* <MetaHeader /> */}
      <div>
        <header className="text-center py-5">
          <h1 className="text-5xl font-bold text-gray-700">WORTHLESS</h1>
        </header>

        <div className="p-5">
          <div className="my-8">
            <h2 className="text-2xl text-gray-600 mb-4">Turn Your Digital Losses into Tax-Savvy Wins</h2>
            <p className="text-gray-500 text-lg">
              At Worthless, we transform the narrative of your underperforming Tokens. Connect your wallet and send us
              your Tokens that have seen better days. In return, we'll send you a nominal amount of native tokens. This
              simple transaction is more than just a trade – it's a strategic move for tax-loss harvesting.
            </p>
          </div>

          <div className="my-8">
            <h3 className="text-xl text-gray-600 mb-3">Smart, Simple, and Strategic</h3>
            <p className="text-gray-500 text-lg">
              Navigating the complex world of Tokens and taxes? We've got you covered. Worthless is designed to help NFT
              collectors and enthusiasts make the most out of their digital investments, even when the market doesn't
              play along.
            </p>
          </div>

          <div className="my-8">
            <h3 className="text-xl text-gray-600 mb-3">How It Works: A Three-Step Process</h3>
            <ul className="list-disc pl-8 text-lg text-gray-500">
              <li>
                <strong>Connect Your Wallet:</strong> Securely connect your digital wallet to our platform.
              </li>
              <li>
                <strong>Select Your Tokens:</strong> Choose the Tokens that have decreased in value and are ripe for
                tax-loss harvesting.
              </li>
              <li>
                <strong>Approve Your Tokens:</strong> Approve your "Worthless" tokens for transfer to our platform.
              </li>
              <li>
                <strong>Complete the Transaction:</strong> Transfer your chosen Tokens to Worthless. We'll send back a
                small amount of cryptocurrency, establishing a 'sale' event for tax purposes.
              </li>
            </ul>
          </div>

          <div className="my-8">
            <h3 className="text-xl text-gray-600 mb-3">Capitalize on Your NFT Investments</h3>
            <p className="text-gray-500 text-lg">
              Realize Your Losses: Convert your digital downturns into potential tax advantages.
            </p>
            <p className="text-gray-500 text-lg">
              Simplify Your Tax Strategy: Let Worthless streamline your tax-loss harvesting process.
            </p>
            <p className="text-gray-500 text-lg">
              Stay Ahead of the Curve: With up-to-date market insights, make informed decisions about when to harvest
              losses.
            </p>
          </div>

          <div className="my-8">
            <h3 className="text-xl text-gray-600 mb-3">Join the Savvy Side of NFT Collecting</h3>
            <p className="text-gray-500 text-lg">
              Worthless isn't just a platform; it's a strategic tool in the modern NFT collector's arsenal. Embrace the
              smarter way to manage your digital assets and optimize your tax situation.
            </p>
          </div>
        </div>
        <div className="text-center my-8">
          <Link href="/harvest">
            <a className="btn btn-primary">Get Started</a> {/* Adjust the styling as needed */}
          </Link>
        </div>

        <footer className="text-center py-5">
          <i className="text-gray-600 text-lg">
            Disclaimer: Worthless does not offer tax advice. Please consult with a tax professional for personalized
            guidance.
          </i>
        </footer>
      </div>
    </>
  );
};
export default Home;

// const Home: NextPage = () => {
//   return (
//     <>
//       <MetaHeader />
//       <div className="flex items-center flex-col flex-grow pt-10">
//         <div className="px-5">
//           <h1 className="text-center mb-8">
//             {/* <span className="block text-2xl mb-2">Welcome to</span> */}
//             <span className="block text-4xl font-bold">CoqInu Rug Cleaner</span>
//           </h1>
//           <p className="text-center text-lg">Do you have rugged tokens in your wallet? We all do.</p>
//           <p className="text-center text-lg">Clean out your rugs with CoqInu Rug Cleaner.</p>
//           <button className="text-lg btn btn-primary mt-8">
//             <Link href="/how" passHref>
//               How Does It Work?
//             </Link>
//           </button>
//         </div>

//         <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
//           <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
//             <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
//               <CurrencyDollarIcon className="h-8 w-8 fill-secondary" />
//               <p>
//                 Clean ERC20 Tokens{" "}
//                 {/* <Link href="/debug" passHref className="link">
//                   Debug Contract
//                 </Link>{" "} */}
//               </p>
//             </div>
//             <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
//               <TicketIcon className="h-8 w-8 fill-secondary" />
//               <p>
//                 {" "}
//                 <Link href="/harvest721" passHref className="link">
//                   Clean ERC721 tokens{" "}
//                 </Link>{" "}
//               </p>
//             </div>
//             <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
//               <PuzzlePieceIcon className="h-8 w-8 fill-secondary" />
//               <p>
//                 Clean ERC1155 tokens{" "}
//                 {/* <Link href="/blockexplorer" passHref className="link">
//                   Block Explorer
//                 </Link>{" "} */}
//               </p>
//             </div>
//           </div>
//         </div>
//       </div>
//     </>
//   );
// };

// export default Home;
