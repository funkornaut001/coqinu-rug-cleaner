/* eslint-disable react/no-unescaped-entities */
import type { NextPage } from "next";

const How: NextPage = () => {
  return (
    <div className="px-10 py-8">
      <h1 className="text-2xl font-bold mb-4">What Is It?</h1>
      <p className="mb-4">
        CoqInu Rug Cleaner is a smart contract based tax loss harvesting tool that allows you to clean out rugged tokens
        from your wallet and write off the losses in a compliant way.
      </p>
      <h1 className="text-2xl font-bold mb-4">How Does It Work?</h1>
      <p>
        It's very simple you send the rugged tokens you have to the CoqInuRugCleaner contract, along with a small
        service fee in $COQ, and the contract "pays" you back with 1,000,000 $COQ tokens
      </p>
    </div>
  );
};

export default How;
