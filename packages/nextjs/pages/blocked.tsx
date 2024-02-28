import type { NextPage } from "next";

const Blocked: NextPage = () => {
  return (
    <div className="flex items-center justify-center h-screen">
      <h1 className="text-center text-3xl font-bold">This address is blocked from using this dApp.</h1>
    </div>
  );
};

export default Blocked;
