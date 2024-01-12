import Link from "next/link";
import type { NextPage } from "next";
import { CurrencyDollarIcon, PuzzlePieceIcon, TicketIcon } from "@heroicons/react/24/outline";
import { MetaHeader } from "~~/components/MetaHeader";

const Home: NextPage = () => {
  return (
    <>
      <MetaHeader />
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <h1 className="text-center mb-8">
            {/* <span className="block text-2xl mb-2">Welcome to</span> */}
            <span className="block text-4xl font-bold">CoqInu Rug Cleaner</span>
          </h1>
          <p className="text-center text-lg">Do you have rugged tokens in your wallet? We all do.</p>
          <p className="text-center text-lg">Clean out your rugs with CoqInu Rug Cleaner.</p>
          <button className="text-lg btn btn-primary mt-8">
            <Link href="/how" passHref>
              How Does It Work?
            </Link>
          </button>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <CurrencyDollarIcon className="h-8 w-8 fill-secondary" />
              <p>
                Clean ERC20 Tokens{" "}
                {/* <Link href="/debug" passHref className="link">
                  Debug Contract
                </Link>{" "} */}
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <TicketIcon className="h-8 w-8 fill-secondary" />
              <p>
                {" "}
                <Link href="/harvest721" passHref className="link">
                  Clean ERC721 tokens{" "}
                </Link>{" "}
              </p>
            </div>
            <div className="flex flex-col bg-base-100 px-10 py-10 text-center items-center max-w-xs rounded-3xl">
              <PuzzlePieceIcon className="h-8 w-8 fill-secondary" />
              <p>
                Clean ERC1155 tokens{" "}
                {/* <Link href="/blockexplorer" passHref className="link">
                  Block Explorer
                </Link>{" "} */}
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
