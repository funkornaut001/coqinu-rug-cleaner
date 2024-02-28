// This is server-side code.
import { NextApiRequest, NextApiResponse } from "next";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "POST") {
    const address = req.body.address; // The Ethereum address sent from the frontend
    const apiKey = process.env.NEXT_PUBLIC_HARPIE_API; // Keep this secret!

    // Making the API call to Harpie
    const harpieResponse = await fetch("https://api.harpie.io/v2/validateAddress", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        apiKey,
        address,
      }),
    });

    const data = await harpieResponse.json(); // Parsing the response from Harpie

    res.status(200).json(data); // Sending the data back to the frontend
  } else {
    res.setHeader("Allow", ["POST"]);
    res.status(405).end("Method Not Allowed");
  }
}
